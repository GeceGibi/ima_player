import Flutter
import UIKit

public class ImaPlayerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        registrar.register(
            ImaPlayerViewFactory(registrar: registrar),
            withId: "gece.dev/imaplayer_view"
        )
    }
}
