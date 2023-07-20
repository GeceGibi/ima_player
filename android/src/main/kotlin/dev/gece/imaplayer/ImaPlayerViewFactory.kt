package dev.gece.imaplayer

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ImaPlayerViewFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    @RequiresApi(Build.VERSION_CODES.N)
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return ImaPlayerView(
            context, id, args as Map<String, Any>, messenger
        )
    }
}


