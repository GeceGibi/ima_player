package dev.gece.imaplayer

import android.content.Context
import android.net.Uri
import android.os.Build
import android.view.View
import androidx.annotation.RequiresApi
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.datasource.DefaultDataSource
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
    private var context: Context,
    private var id: Int,
    private var args: Map<String, Any>,
    private var messenger: BinaryMessenger
) : PlatformView, Player.Listener {

    private enum class EventType {
        ADS,
        PLAYER
    }

    private val tag = "IMA_PLAYER/$id"

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventSink? = null

    // Video Player
    private val playerView: PlayerView
    private val player: ExoPlayer

    // Ads
    private val adsLoader: ImaAdsLoader

    // Passed arguments
    private var videoUrl: Uri? = null
    private var imaTag: Uri? = null
    private val isMuted: Boolean
    private val isMixed: Boolean
    private val autoPlay: Boolean


    override fun getView(): View {
        return playerView
    }

    override fun dispose() {
        player.removeListener(this)
        player.release()

        playerView.removeAllViews()
        playerView.player = null

        adsLoader.setPlayer(null)
        adsLoader.release()

        methodChannel = null
        eventChannel = null
        eventSink = null
    }

    private fun setupChannels() {
        methodChannel = MethodChannel(messenger, "gece.dev/imaplayer/$id")
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> play(call.arguments as String?, result)
                "pause" -> pause(result)
                "stop" -> stop(result)
                "view_created" -> viewCreated(result)
                "seek_to" -> seekTo(call.arguments as Int?, result)
                "set_volume" -> setVolume(call.arguments as Double?, result)
                "get_size" -> getSize(result)
                "get_info" -> getInfo(result)
                "skip_ad" -> skipAd(result)
                "dispose" -> viewDispose(result)
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

    init {
        /// get and set arguments
        videoUrl = Uri.parse(args["video_url"] as String?)
        imaTag = Uri.parse(args["ima_tag"] as String?)
        isMuted = args["is_muted"] as Boolean? == true
        isMixed = args["is_mixed"] as Boolean? ?: true
        autoPlay = args["auto_play"] as Boolean? ?: true

        setupChannels()

        playerView = PlayerView(context)
        playerView.setShowNextButton(false)
        playerView.setShowPreviousButton(false)
        playerView.setShowShuffleButton(false)
        playerView.setShowSubtitleButton(false)
        playerView.setShowVrButton(false)
        playerView.controllerAutoShow = args["controller_auto_show"] as Boolean? ?: true
        playerView.controllerHideOnTouch = args["controller_hide_on_touch"] as Boolean? ?: true
        playerView.useController = args["show_playback_controls"] as Boolean? ?: true

        adsLoader = ImaAdsLoader.Builder(context)
            .setAdEventListener { event -> sendEvent(EventType.ADS, event.type.name) }
            .build()

        // Set up the factory for media sources, passing the ads loader and ad view providers.
        val dataSourceFactory = DefaultDataSource.Factory(context)
        val mediaSourceFactory = DefaultMediaSourceFactory(dataSourceFactory)
            .setAdsLoaderProvider { adsLoader }
            .setAdViewProvider(playerView)

        // Create an ExoPlayer and set it as the player for content and ads.
        player = ExoPlayer.Builder(context)
            .setMediaSourceFactory(mediaSourceFactory)
            .setDeviceVolumeControlEnabled(true)
            .build()

        player.playWhenReady = autoPlay
        player.setAudioAttributes(
            AudioAttributes.Builder().setContentType(C.AUDIO_CONTENT_TYPE_MOVIE).build(),
            !isMixed
        )

        if (isMuted) {
            player.volume = 0.0F
        }

        player.addListener(this)
        playerView.player = player
        adsLoader.setPlayer(player)

        preparePlayer()
    }

    override fun onPlaybackStateChanged(playbackState: Int) {
        super.onPlaybackStateChanged(playbackState)
        when (playbackState) {
            ExoPlayer.STATE_READY -> sendEvent(EventType.PLAYER, "READY")
            ExoPlayer.STATE_BUFFERING -> sendEvent(EventType.PLAYER, "BUFFERING")
        }
    }

    override fun onIsPlayingChanged(isPlaying: Boolean) {
        super.onIsPlayingChanged(isPlaying)
        sendEvent(EventType.PLAYER, if (isPlaying) "PLAYING" else "PAUSED")
    }

    private fun preparePlayer() {
        val mediaItem = MediaItem.Builder().setUri(videoUrl)
            .setAdsConfiguration(imaTag?.let {
                MediaItem.AdsConfiguration.Builder(it).build()
            }).build()

        player.setMediaItem(mediaItem)
        player.prepare()
    }


    private fun play(videoUrl: String?, result: MethodChannel.Result) {
        if (videoUrl != null) {
            this.videoUrl = Uri.parse(videoUrl)
            player.stop()
            player.clearMediaItems()
            adsLoader.skipAd()
            preparePlayer()
        }

        player.playWhenReady = true
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

    private fun seekTo(duration: Int?, result: MethodChannel.Result) {
        if (duration != null) {
            player.seekTo(duration.toLong())
        }

        result.success(duration != null)
    }

    private fun setVolume(value: Double?, result: MethodChannel.Result) {
        if (value != null) {
            player.volume = 0.0.coerceAtLeast(1.0.coerceAtMost(value)).toFloat()
        }

        result.success(value != null)
    }

    private fun skipAd(result: MethodChannel.Result) {
        if (player.isPlayingAd) {
            adsLoader.skipAd()
        }

        result.success(player.isPlayingAd)
    }

    private fun getSize(result: MethodChannel.Result) {
        result.success(
            hashMapOf(
                "height" to player.videoSize.height,
                "width" to player.videoSize.width
            )
        )
    }

    private fun viewCreated(result: MethodChannel.Result) {
        result.success(true)
    }

    private fun viewDispose(result: MethodChannel.Result) {
        result.success(true)
    }

    private fun getInfo(result: MethodChannel.Result) {
        result.success(
            hashMapOf(
                "current_position" to player.currentPosition,
                "total_duration" to player.duration,
                "is_playing" to (player.isPlaying && !player.isPlayingAd),
                "is_playing_ad" to player.isPlayingAd,
                "is_buffering" to (player.bufferedPercentage != 0 && player.bufferedPercentage != 100),
            )
        )
    }

    private fun sendEvent(type: EventType, value: Any?) {
        eventSink?.success(
            hashMapOf("type" to type.name.lowercase(), "value" to value)
        )
    }
}

