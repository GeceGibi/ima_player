@file:OptIn(UnstableApi::class)

package dev.gece.imaplayer

import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import androidx.annotation.OptIn
import androidx.annotation.RequiresApi
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaItem.AdsConfiguration
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.VideoSize
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.ima.ImaAdsLoader
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.ui.PlayerView
import com.google.ads.interactivemedia.v3.api.AdErrorEvent
import com.google.ads.interactivemedia.v3.api.AdErrorEvent.AdErrorListener
import com.google.ads.interactivemedia.v3.api.AdEvent
import com.google.ads.interactivemedia.v3.api.AdEvent.AdEventListener
import com.google.ads.interactivemedia.v3.api.AdsManager
import com.google.ads.interactivemedia.v3.api.ImaSdkSettings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.Timer
import java.util.TimerTask


@RequiresApi(Build.VERSION_CODES.N)
internal class ImaPlayerView(
    private var context: Context,
    private var id: Int,
    private var messenger: BinaryMessenger,
    private val imaSdkSettings: ImaSdkSettings,
    private val imaPlayerSettings: ImaPlayerSettings,
    private val headers: HashMap<String, String>
) : PlatformView, AdEventListener, AdErrorListener {
    private val tag = "IMA_PLAYER/$id"

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventSink? = null

    // Video Player
    private var playerView: PlayerView = PlayerView(context)
    private var exoPlayer: ExoPlayer = ExoPlayer.Builder(context).build()

    // Ads
    private var adsLoader = ImaAdsLoader.Builder(context)
        .setImaSdkSettings(imaSdkSettings)
        .setAdErrorListener(this)
        .setAdEventListener(this)
        .build()

    private var adsManager: AdsManager? = null

    private val userAgent = "User-Agent"
    private val httpDataSourceFactory = DefaultHttpDataSource.Factory()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun getView(): View {
        return playerView
    }

    init {
        setChannels()
        setAudioAttributes()

        buildHttpDataSourceFactory(headers)

        playerView.player = exoPlayer;
        playerView.setControllerHideDuringAds(true)

        if (!imaPlayerSettings.showPlaybackControls) {
            playerView.controllerAutoShow = false
            playerView.useController = imaPlayerSettings.showPlaybackControls
        }

        adsLoader.setPlayer(exoPlayer);

        val dataSourceFactory: DataSource.Factory =
            DefaultDataSource.Factory(context, httpDataSourceFactory)

        val mediaSourceWithAdFactory = DefaultMediaSourceFactory(context)
            .setDataSourceFactory(dataSourceFactory)
            .setLocalAdInsertionComponents({ _ -> adsLoader }, playerView)

        exoPlayer.volume = imaPlayerSettings.initialVolume.toFloat()

        exoPlayer.addListener(object : Player.Listener {

            override fun onPlayerError(error: PlaybackException) {
                super.onPlayerError(error)
                eventSink?.error("player_error", error.message, null)
            }

            override fun onVideoSizeChanged(videoSize: VideoSize) {
                super.onVideoSizeChanged(videoSize)

                if (videoSize.width == 0 || videoSize.height == 0) {
                    return;
                }

                val event = HashMap<String, Any>()
                event["type"] = "size_changed"
                event["size"] = listOf(videoSize.width, videoSize.height)
                sendEvent(event)
            }

            override fun onVolumeChanged(volume: Float) {
                super.onVolumeChanged(volume)
                val event = HashMap<String, Any>()
                event["type"] = "volume"
                event["volume"] = volume.toDouble()
                sendEvent(event)
            }

            override fun onPlaybackStateChanged(playbackState: Int) {
                super.onPlaybackStateChanged(playbackState)

                when (playbackState) {
                    Player.STATE_BUFFERING -> {

                    }

                    Player.STATE_ENDED -> {
                        val event = HashMap<String, Any>()
                        event["type"] = "ended"
                        sendEvent(event)
                    }

                    Player.STATE_READY -> {
                        sendContentDuration(exoPlayer.duration)
                        val event = HashMap<String, Any>()
                        event["type"] = "ready"
                        sendEvent(event)

                        mainHandler.removeCallbacks(bufferTracker)
                        mainHandler.post(bufferTracker)
                    }

                    Player.STATE_IDLE -> {
                        // no-op
                    }
                }
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                super.onIsPlayingChanged(isPlaying)
                val event = HashMap<String, Any>()
                event["type"] = if (isPlaying && !exoPlayer.isPlayingAd) "playing" else "paused"
                sendEvent(event)
            }
        })

        val mediaItem = generateMediaItem(imaPlayerSettings.uri)
        exoPlayer.addMediaSource(mediaSourceWithAdFactory.createMediaSource(mediaItem))
        exoPlayer.prepare();
        exoPlayer.playWhenReady = imaPlayerSettings.autoPlay;
    }

    var bufferTracker = object : Runnable {
        private var latestBufferedPosition: Long = 0L
        private var isBuffering = false

        fun sendBufferEvent(buffering: Boolean) {
            if (isBuffering != buffering) {
                isBuffering = buffering
                sendEvent(
                    hashMapOf(
                        "type" to if (isBuffering) "buffering_start" else "buffering_end"
                    )
                )
            }
        }

        override fun run() {
            val hasBuffering = latestBufferedPosition != exoPlayer.bufferedPosition

            if (hasBuffering) {
                latestBufferedPosition = exoPlayer.bufferedPosition;

                sendEvent(
                    hashMapOf(
                        "type" to "buffered_duration",
                        "duration" to latestBufferedPosition,
                    )
                )
            }

            sendBufferEvent(hasBuffering)
            mainHandler.postDelayed(this, 250)
        }
    }

    private fun setAudioAttributes() {
        exoPlayer.setAudioAttributes(
            AudioAttributes.Builder().setContentType(C.AUDIO_CONTENT_TYPE_MOVIE).build(),
            !imaPlayerSettings.isMixed
        )
    }

    private fun generateMediaItem(uri: Uri): MediaItem {
        val builder = MediaItem.Builder().setUri(uri)

        if (imaPlayerSettings.isAdsEnabled) {
            builder.setAdsConfiguration(AdsConfiguration.Builder(imaPlayerSettings.tag!!).build())
        }

        return builder.build();
    }


    private fun buildHttpDataSourceFactory(httpHeaders: HashMap<String, String>) {
        val httpHeadersNotEmpty = httpHeaders.isNotEmpty()
        val userAgent =
            if (httpHeadersNotEmpty && httpHeaders.containsKey(userAgent)) httpHeaders[userAgent] else "ExoPlayer"
        httpDataSourceFactory.setUserAgent(userAgent).setAllowCrossProtocolRedirects(true)

        if (httpHeadersNotEmpty) {
            httpDataSourceFactory.setDefaultRequestProperties(httpHeaders)
        }
    }

    private fun setChannels() {
        methodChannel = MethodChannel(messenger, "gece.dev/imaplayer/$id")
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> play(call.arguments as String?, result)
                "pause" -> pause(result)
                "stop" -> stop(result)
                "seek_to" -> seekTo(call.arguments as Int?, result)
                "set_volume" -> setVolume(call.arguments as Double?, result)
                "skip_ad" -> skipAd(result)
                "current_position" -> getCurrentPosition(result)
                "view_created" -> result.success(null)
                "dispose" -> result.success(null)
                else -> result.notImplemented()
            }
        }

        eventChannel = EventChannel(messenger, "gece.dev/imaplayer/$id/events")
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(o: Any?, sink: EventSink) {
                eventSink = sink
            }

            override fun onCancel(o: Any?) {
                eventSink = null
            }
        })
    }

    private fun play(videoUrl: String?, result: MethodChannel.Result) {
        if (videoUrl != null) {
            exoPlayer.clearMediaItems()
            exoPlayer.addMediaItem(generateMediaItem(Uri.parse(videoUrl)))
        }

        exoPlayer.playWhenReady = true
        result.success(null)
    }

    private fun pause(result: MethodChannel.Result) {
        exoPlayer.playWhenReady = false
        result.success(null)
    }

    private fun stop(result: MethodChannel.Result) {
        exoPlayer.stop()
        result.success(null)
    }

    private fun seekTo(duration: Int?, result: MethodChannel.Result) {
        if (duration != null) {
            exoPlayer.seekTo(duration.toLong())
        }

        result.success(null)
    }

    private fun getCurrentPosition(result: MethodChannel.Result) {
        try {
            result.success(exoPlayer.currentPosition)
        } catch (e: Exception) {
            result.error("player_error", e.message, null)
        }
    }

    private fun setVolume(value: Double?, result: MethodChannel.Result) {
        if (value != null) {
            exoPlayer.volume = value.toFloat()
        }

        result.success(value != null)
    }

    private fun skipAd(result: MethodChannel.Result) {
        adsManager?.skip()
        result.success(null)
    }

    private fun sendEvent(value: HashMap<String, Any>) {
        eventSink?.success(value)
    }

    private fun sendContentDuration(duration: Long) {
        val value = HashMap<String, Any>()
        value["type"] = "duration"
        value["value"] = duration
        sendEvent(value)
    }


    private var adEvent: AdEvent.AdEventType? = null;
    override fun onAdEvent(event: AdEvent) {
        if (adEvent == event.type) return
        adEvent = event.type;

        when (adEvent) {
            AdEvent.AdEventType.LOADED -> {
                val info = HashMap<String, Any>()
                info["duration"] = event.ad.duration
                info["ad_id"] = event.ad.adId
                info["size"] = listOf(event.ad.vastMediaWidth, event.ad.vastMediaHeight)
                info["advertiser_name"] = event.ad.advertiserName
                info["ad_system"] = event.ad.adSystem
                info["content_type"] = event.ad.contentType
                info["description"] = event.ad.description
                info["bitrate"] = event.ad.vastMediaBitrate
                info["title"] = event.ad.title
                info["skippable"] = event.ad.isSkippable
                info["linear"] = event.ad.isLinear
                info["ui_disabled"] = event.ad.isUiDisabled
                info["skip_time_offset"] = event.ad.skipTimeOffset
                info["is_bumper"] = event.ad.adPodInfo.isBumper
                info["total_ads"] = event.ad.adPodInfo.totalAds

                val value = HashMap<String, Any>()
                value["type"] = "ad_info"
                value["info"] = info
                sendEvent(value)
            }

            AdEvent.AdEventType.CONTENT_RESUME_REQUESTED -> {
                sendContentDuration(exoPlayer.duration)
            }

            else -> {}
        }

        val value = HashMap<String, Any>()
        value["type"] = "ad_event"
        value["value"] = adEvent!!.name.lowercase()
        sendEvent(value)
    }

    override fun onAdError(event: AdErrorEvent) {
        eventSink?.error(
            "ad_error",
            "${event.error.errorCode.name}, ${event.error.message}",
            null
        )
    }

    override fun dispose() {
        mainHandler.removeCallbacks(bufferTracker)

        exoPlayer.release()

        playerView.removeAllViews()
        playerView.player = null

        adsLoader.setPlayer(null)
        adsLoader.release()

        methodChannel = null
        eventChannel = null
        eventSink = null
    }
}

