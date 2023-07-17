package dev.gece.imaplayer

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** ImaPlugin */
class ImaPlayerPlugin : FlutterPlugin {
    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        binding.platformViewRegistry.registerViewFactory(
            "dev.gece.imaplayer.view", ImaPlayerViewFactory(binding.binaryMessenger)
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {

    }
}
