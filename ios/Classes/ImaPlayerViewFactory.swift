//
//  ImaPlayerViewFactory.swift
//  ima_player
//
//  Created by Ömer Güven on 19.07.2023.
//

import Foundation
import Flutter
import UIKit

class ImaPlayerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect,  viewIdentifier viewId: Int64, arguments args: Any? ) -> FlutterPlatformView {
        return ImaPlayerView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args as! Dictionary<String, Any>,
            binaryMessenger: messenger)
    }
}
