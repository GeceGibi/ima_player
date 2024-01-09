package dev.gece.imaplayer

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import com.google.ads.interactivemedia.v3.api.ImaSdkFactory
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ImaPlayerViewFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    @RequiresApi(Build.VERSION_CODES.N)
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        val payload = args as Map<String, Any>;

        val adsLoaderSettings = payload["ads_loader_settings"] as HashMap<*, *>
        val imaSdkSettings = ImaSdkFactory.getInstance().createImaSdkSettings()

        if (adsLoaderSettings["ppid"] is String) {
            imaSdkSettings.ppid = adsLoaderSettings["ppid"] as String
        }
        imaSdkSettings.language = adsLoaderSettings["language"] as String
        imaSdkSettings.isDebugMode = adsLoaderSettings["enable_debug_mode"] as Boolean

        val imaPlayerSettings = ImaPlayerSettings(
            payload["uri"] as String,
            payload["ima_tag"] as? String?
        )

        imaPlayerSettings.isMixed = payload["is_mixed"] as Boolean;
        imaPlayerSettings.autoPlay = payload["auto_play"] as Boolean;
        imaPlayerSettings.initialVolume = payload["initial_volume"] as Double;
        imaPlayerSettings.showPlaybackControls = payload["show_playback_controls"] as Boolean

        var headers = HashMap<String, String>()
        if (payload["headers"] is HashMap<*, *>) {
            headers = payload["headers"] as HashMap<String, String>
        }

        return ImaPlayerView(
            context,
            id,
            messenger,
            imaSdkSettings,
            imaPlayerSettings,
            headers
        )
    }
}


