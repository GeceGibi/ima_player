package dev.gece.imaplayer

import android.content.Context
import android.net.Uri
import android.os.Build
import android.view.View
import androidx.annotation.RequiresApi
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.ForwardingPlayer
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackParameters
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
    context: Context,
    id: Int,
    args: Map<String, Any>,
    messenger: BinaryMessenger,
) : PlatformView {

    private var tag = "IMA_PLAYER/$id"

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventSink? = null

    // Video Player
    private val playerView: PlayerView
    private var exoPlayer: ExoPlayer
    private var player: Player

    // Ima
    private var vastUrl: String? = null
    private var adsLoader: ImaAdsLoader

    override fun getView(): View {
        return playerView
    }

    override fun dispose() {
        player.release()

        playerView.removeAllViews()
        playerView.player = null

        adsLoader.setPlayer(null)
        adsLoader.release()

        methodChannel = null
        eventChannel = null
        eventSink = null
    }

    init {
        val videoUrl = args["video_url"] as String? ?: ""
        vastUrl = args["ima_tag"] as String? ?: ""

        methodChannel = MethodChannel(messenger, "gece.dev/imaplayer/$id")
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> play(call.argument("video_url"), result)
                "pause" -> pause(result)
                "stop" -> stop(result)
                "view_created" -> viewCreated()
                "seek_to" -> seekTo(call.arguments as Int?, result)
                "set_volume" -> setVolume(call.arguments as Double?, result)
                "get_size" -> getSize(result)
                "get_info" -> getInfo(result)
                "skip_ad" -> skipAd(result)
                "dispose" -> viewDispose()
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

        adsLoader = ImaAdsLoader.Builder(context)
            .setAdErrorListener { event ->
                eventSink?.error(
                    event.error.errorCode.name,
                    event.error.message,
                    event.error
                )
            }
            .setAdEventListener { event -> sendEvent("ads", event.type.name) }
            .build()

        playerView = PlayerView(context)
        playerView.setShowNextButton(false)
        playerView.setShowPreviousButton(false)
        playerView.setShowShuffleButton(false)
        playerView.setShowSubtitleButton(false)
        playerView.setShowVrButton(false)

        playerView.controllerAutoShow = args["controller_auto_show"] as Boolean? ?: true
        playerView.controllerHideOnTouch = args["controller_hide_on_touch"] as Boolean? ?: true
        playerView.useController = args["show_playback_controls"] as Boolean? ?: true

        // Set up the factory for media sources, passing the ads loader and ad view providers.
        val dataSourceFactory = DefaultDataSource.Factory(context)
        val mediaSourceFactory = DefaultMediaSourceFactory(dataSourceFactory)
            .setAdsLoaderProvider { adsLoader }
            .setAdViewProvider(playerView)


        // Create an ExoPlayer and set it as the player for content and ads.
        exoPlayer = ExoPlayer.Builder(context).setMediaSourceFactory(mediaSourceFactory).build()
        exoPlayer.setAudioAttributes(
            AudioAttributes.Builder().setContentType(C.AUDIO_CONTENT_TYPE_MOVIE).build(),
            !(args["is_mixed"] as Boolean? ?: true)
        )

        player = object : ForwardingPlayer(exoPlayer) {
            override fun isCommandAvailable(command: @Player.Command Int): Boolean {
                return when (command) {
                    COMMAND_SET_SPEED_AND_PITCH, COMMAND_GET_AUDIO_ATTRIBUTES -> false
                    else -> super.isCommandAvailable(command)
                }
            }

            override fun getAvailableCommands(): Player.Commands {
                return super.getAvailableCommands()
                    .buildUpon()
                    .addAllCommands()
                    .removeAll(COMMAND_SET_SPEED_AND_PITCH, COMMAND_GET_AUDIO_ATTRIBUTES)
                    .build()
            }

            override fun setPlaybackParameters(playbackParameters: PlaybackParameters) {
                // Setting speed and pitch is disabled
            }

            override fun setPlaybackSpeed(speed: Float) {
                // Setting speed and pitch is disabled
            }
        }

        player.playWhenReady = args["auto_play"] as Boolean? ?: false


        if (args["is_muted"] as Boolean? == true) {
            player.volume = 0.0F
        }

        player.addListener(object : Player.Listener {
            override fun onPlaybackStateChanged(playbackState: Int) {
                super.onPlaybackStateChanged(playbackState)
                when (playbackState) {
                    ExoPlayer.STATE_READY -> sendEvent("player", "READY")
                    ExoPlayer.STATE_BUFFERING -> sendEvent("player", "BUFFERING")
                }
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                super.onIsPlayingChanged(isPlaying)
                sendEvent(
                    "player",
                    if (isPlaying) "PLAYING" else "PAUSED"
                )
            }
        })



        playerView.artworkDisplayMode = PlayerView.ARTWORK_DISPLAY_MODE_FIT
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
            player.stop()
            player.clearMediaItems()
            adsLoader.skipAd()
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

    private fun viewCreated() {}
    private fun viewDispose() {}

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

    private fun sendEvent(type: String, value: Any) {
        eventSink?.success(
            hashMapOf(
                "type" to type,
                "value" to value,
            )
        )
    }
}