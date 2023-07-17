package dev.gece.imaplayer

import android.content.Context
import android.net.Uri
import android.os.Build
import android.util.Log
import android.view.View
import androidx.annotation.RequiresApi
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.ima.ImaAdsLoader
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.ui.PlayerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView


@RequiresApi(Build.VERSION_CODES.N)
internal class ImaPlayerView(
    context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?,
    messenger: BinaryMessenger,
) : PlatformView {

    private var tag = "IMA_PLAYER/$id"
    private val httpDataSourceFactory = DefaultHttpDataSource.Factory()

    private var methodChannel: MethodChannel? = null
    private var playerEventChannel: EventChannel? = null
    private var playerEventSink: EventSink? = null
    private var adsEventChannel: EventChannel? = null
    private var adsEventSink: EventSink? = null

    // Video Player
    private val playerView: PlayerView
    private var player: ExoPlayer

    // Ima
    private var vastUrl: String? = null
    private var adsLoader: ImaAdsLoader

    override fun getView(): View {
        return playerView
    }

    override fun dispose() {
        playerView.removeAllViews()
        adsLoader.setPlayer(null)
        playerView.player = null
        player.release()

        methodChannel = null
        playerEventChannel = null
        playerEventSink = null

    }

    init {

        val videoUrl = (creationParams?.get("video_url") ?: "") as String
        vastUrl = (creationParams?.get("vast_url") ?: "") as String

        methodChannel = MethodChannel(messenger, "dev.gece.imaplayer/$id")
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> play(call.argument("video_url"), result)
                "pause" -> pause(result)
                "stop" -> stop(result)
                "seek_to" -> seekTo(call.argument<Long>("duration"), result)
                "get_size" -> getSize(result)
                "get_info" -> getInfo(result)
                else -> result.notImplemented()
            }
        }

        playerEventChannel = EventChannel(messenger, "dev.gece.imaplayer_events/$id")
        playerEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(o: Any?, sink: EventSink) {
                playerEventSink = sink
            }

            override fun onCancel(o: Any?) {
                playerEventSink = null
            }
        })

        adsEventChannel = EventChannel(messenger, "dev.gece.imaplayer_ads_events/$id")
        adsEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(o: Any?, sink: EventSink) {
                adsEventSink = sink
            }

            override fun onCancel(o: Any?) {
                adsEventSink = null
            }
        })

        Log.w(tag, id.toString())

        adsLoader = ImaAdsLoader.Builder(context)
            .setAdErrorListener { event ->
                adsEventSink?.error(
                    event.error.errorCode.name,
                    event.error.message,
                    event.error
                )
            }
            .setAdEventListener { event -> adsEventSink?.success(event.type.ordinal) }
            .build()

        playerView = PlayerView(context)
        playerView.setShowNextButton(false)
        playerView.setShowPreviousButton(false)
        playerView.setShowShuffleButton(false)
        playerView.setShowSubtitleButton(false)
        playerView.setShowVrButton(false)

        playerView.controllerAutoShow =
            (creationParams?.get("controller_auto_show") ?: true) as Boolean
        playerView.controllerHideOnTouch =
            (creationParams?.get("controller_hide_on_touch") ?: true) as Boolean


        // Set up the factory for media sources, passing the ads loader and ad view providers.
        val dataSourceFactory = DefaultDataSource.Factory(context)
        val mediaSourceFactory =
            DefaultMediaSourceFactory(dataSourceFactory).setAdsLoaderProvider { adsLoader }
                .setAdViewProvider(playerView)


        // Create an ExoPlayer and set it as the player for content and ads.
        player = ExoPlayer.Builder(context).setMediaSourceFactory(mediaSourceFactory).build()
        player.playWhenReady = (creationParams?.get("auto_play") ?: false) as Boolean
        player.addListener(object : Player.Listener {
            override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                playerEventSink?.success(playbackState)
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                super.onIsPlayingChanged(isPlaying)
            }
        })

        player.setAudioAttributes(
            AudioAttributes.Builder().setContentType(C.AUDIO_CONTENT_TYPE_MOVIE).build(),
            true
        )

        playerView.player = player
        adsLoader.setPlayer(player)

        preparePlayer(videoUrl)
    }

    private fun preparePlayer(videoUrl: String) {
        val contentUri = Uri.parse(videoUrl)
        val adTagUri = Uri.parse(vastUrl)
        val mediaItem = MediaItem.Builder().setUri(contentUri)
            .setAdsConfiguration(MediaItem.AdsConfiguration.Builder(adTagUri).build()).build()

        player.setMediaItem(mediaItem)
        player.prepare()
    }

    private fun play(videoUrl: String?, result: MethodChannel.Result) {

        if (videoUrl != null) {
            adsLoader.skipAd();
            preparePlayer(videoUrl)
        }

        player.play()
        result.success(true)
    }

    private fun pause(result: MethodChannel.Result) {
        player.pause()
        result.success(true)
    }

    private fun stop(result: MethodChannel.Result) {
        player.stop()
        result.success(true)
    }

    private fun seekTo(duration: Long?, result: MethodChannel.Result) {
        if (duration != null) {
            player.seekTo(duration)
        }
        result.success(duration != null)
    }

    private fun setVolume(value: Double) {
        player.volume = 0.0.coerceAtLeast(1.0.coerceAtMost(value)).toFloat()
    }

    private fun getSize(result: MethodChannel.Result) {
        var size = HashMap<String, Int>()
        size["height"] = player.videoFormat?.height ?: 0
        size["width"] = player.videoFormat?.width ?: 0
        result.success(size)
    }

    private fun getInfo(result: MethodChannel.Result) {
        var info = HashMap<String, Any>()
        info["aspect_ratio"] = player.videoFormat?.pixelWidthHeightRatio ?: 1.0
        info["average_bitrate"] = player.videoFormat?.averageBitrate ?: 0
        result.success(info)
    }


}