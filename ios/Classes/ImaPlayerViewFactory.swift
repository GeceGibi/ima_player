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
    private var registrar: FlutterPluginRegistrar

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar;
        super.init()
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect,  viewIdentifier viewId: Int64, arguments args: Any? ) -> FlutterPlatformView {
        var methodChannel = FlutterMethodChannel(name: "gece.dev/imaplayer/\(viewId)", binaryMessenger: registrar.messenger())
        var eventChannel = FlutterEventChannel(name: "gece.dev/imaplayer/\(viewId)/events", binaryMessenger: registrar.messenger())
        
        let payload = args as! Dictionary<String, Any>
        
        let adsLoaderSettings = payload["ads_loader_settings"] as! Dictionary<String, Any>
        let imaSdkSettings  = IMASettings()
        
        
        if adsLoaderSettings["ppid"] is String {
            imaSdkSettings.ppid = (adsLoaderSettings["ppid"] as! String)
        }
    
        imaSdkSettings.language = adsLoaderSettings["language"] as! String
        imaSdkSettings.enableBackgroundPlayback = true
        
        var imaPlayerSettings = ImaPlayerSettings()
        let uri = payload["uri"] as! String;
        
        imaPlayerSettings.tag = payload["ima_tag"] as? String
        imaPlayerSettings.uri = URL(string: uri)
        imaPlayerSettings.autoPlay = payload["auto_play"] as! Bool
        imaPlayerSettings.initialVolume = payload["initial_volume"] as! Double
        imaPlayerSettings.isMixed = payload["is_mixed"] as! Bool
        imaPlayerSettings.showPlaybackControls = payload["show_playback_controls"] as! Bool
        
        var headers = Dictionary<String, String>()
        
        if (payload["headers"] is Dictionary<String, Any>) {
            headers = payload["headers"] as! Dictionary<String, String>
        }
        
        if uri.starts(with: "asset://") {
            let assetKey = registrar.lookupKey(forAsset: String(uri.dropFirst(8)))
            let assetPath = Bundle.main.path(forResource: assetKey, ofType: nil)!
            imaPlayerSettings.uri = URL(string: assetPath, relativeTo: Bundle.main.bundleURL)
        }
        
        return ImaPlayerView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args as! Dictionary<String, Any>,
            binaryMessenger: registrar.messenger(),
            imaSdkSettings: imaSdkSettings,
            imaPlayerSettings: imaPlayerSettings,
            headers: headers,
            methodChannel: methodChannel,
            eventChannel: eventChannel
        )
    }
}
