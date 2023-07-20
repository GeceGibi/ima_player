import Flutter
import UIKit

public class ImaPlayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "gece.dev/imaplayer", binaryMessenger: registrar.messenger())
    let instance = ImaPlayerPlugin()

    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(ImaPlayerViewFactory(messenger: registrar.messenger()), withId: "gece.dev/imaplayer")
  }
}

