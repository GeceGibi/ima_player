//
//  ImaPlayerViewFactory.swift
//  ima_player
//
//  Created by Ömer Güven on 19.07.2023.
//

import GoogleInteractiveMediaAds
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
        
        let payload = args as! Dictionary<String, Any>
        
        let adsLoaderSettings = payload["ads_loader_settings"] as! Dictionary<String, Any>
        let imaSdkSettings  = IMASettings()
        
        
        if adsLoaderSettings["ppid"] is String {
            imaSdkSettings.ppid = (adsLoaderSettings["ppid"] as! String)
        }
    
        imaSdkSettings.language = adsLoaderSettings["language"] as! String
        imaSdkSettings.enableBackgroundPlayback = true
        
        var imaPlayerSettings = ImaPlayerSettings()
        
        imaPlayerSettings.tag = payload["ima_tag"] as? String
        imaPlayerSettings.uri = URL(string: payload["uri"] as! String)
        imaPlayerSettings.autoPlay = payload["auto_play"] as! Bool
        imaPlayerSettings.initialVolume = payload["initial_volume"] as! Double
        imaPlayerSettings.isMixed = payload["is_mixed"] as! Bool
        imaPlayerSettings.showPlaybackControls = payload["show_playback_controls"] as! Bool
        
        var headers = Dictionary<String, String>()
        
        if (payload["headers"] is Dictionary<String, Any>) {
            headers = payload["headers"] as! Dictionary<String, String>
        }
        
        return ImaPlayerView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args as! Dictionary<String, Any>,
            binaryMessenger: messenger,
            imaSdkSettings: imaSdkSettings,
            imaPlayerSettings: imaPlayerSettings,
            headers: headers
        )
    }
}
