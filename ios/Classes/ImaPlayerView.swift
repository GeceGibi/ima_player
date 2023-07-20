//
//  ImaPlayerView.swift
//  ima_player
//
//  Created by Ömer Güven on 19.07.2023.
//
import GoogleInteractiveMediaAds
import AVFoundation
import Foundation
import Flutter
import UIKit
import AVKit
import MediaPlayer

class ImaPlayerView: NSObject, FlutterPlatformView, FlutterStreamHandler, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    private var player: AVPlayer!
    private var adsLoader = IMAAdsLoader(settings: nil)
    private var adsManager: IMAAdsManager!
    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    private var avPlayerViewController = AVPlayerViewController()
    
    private var methodChannel: FlutterMethodChannel!
    
    private var eventChannel: FlutterEventChannel!
    private var eventSink: FlutterEventSink!
    
    private var eventChannelAds: FlutterEventChannel!
    private var eventSinkAds: FlutterEventSink!
    
    private let imaTag: String
    private let videoUrl: String
    
    func view() -> UIView {
        return avPlayerViewController.view
    }
    
    func dispose(){
        NotificationCenter.default.removeObserver(self)
    }
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Dictionary<String, Any>?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        imaTag = ((args?["ima_tag"] as? String?) ?? "")!
        videoUrl = ((args?["video_url"] as? String?) ?? "")!
        
        super.init()
        
        
        // 'is_mixed': controller.options.isMixWithOtherMedia,
        // 'auto_play': controller.options.autoPlay,
        // 'video_url': controller.videoUrl,
        
        adsLoader.delegate = self
        
        // Load AVPlayer with path to your content.
        let contentURL = URL(string: videoUrl)!
        
        player = AVPlayer(url: contentURL)
        player.isMuted = ((args?["is_muted"] as? Bool?) ?? false)!
        
        let audioSession = AVAudioSession.sharedInstance()
        let isMixed = ((args?["is_mixed"] as? Bool?) ?? true)!
        
        do {
            if (isMixed){
                try audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
            } else {
                try audioSession.setCategory(AVAudioSession.Category.playback)
            }
        } catch _{
            
        }
        
        
        // avPlayerViewController.showsPlaybackControls
        avPlayerViewController.player = player
        avPlayerViewController.showsPlaybackControls = false
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
        
        
        methodChannel = FlutterMethodChannel(name: "gece.dev/imaplayer/\(viewId)", binaryMessenger: messenger)
        methodChannel.setMethodCallHandler(onMethodCall)
        
        eventChannel = FlutterEventChannel(name: "gece.dev/imaplayer/\(viewId)/events", binaryMessenger: messenger)
        eventChannel.setStreamHandler(self)
        
        // eventChannelAds = FlutterEventChannel(name: "gece.dev/imaplayer/\(viewId)/events_ads", binaryMessenger: messenger)
        
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ImaPlayerView.contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem);
        
    }
    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
        adsLoader.contentComplete()
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    
    // MARK: - IMAAdsLoaderDelegate
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self
        adsManager.initialize(with: nil)
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        print("Error loading ads: " + adErrorData.adError.message!)
        avPlayerViewController.player?.play()
    }
    
    // MARK: - IMAAdsManagerDelegate
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        
        
        // Play each ad once it has been loaded
        if event.type == IMAAdEventType.LOADED {
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {}
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {}
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {}
    
    func requestAds() {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: avPlayerViewController.view, viewController: avPlayerViewController)
        let request = IMAAdsRequest(
            adTagUrl: imaTag,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader.requestAds(with: request)
    }
    
    func viewCreated(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.requestAds()
        }
    }
    
    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch(call.method){
        case "play":
            player?.play()
            result(true)
            break;
            
        case "pause":
            player?.pause()
            result(true)
            break;
            
        case "stop":
            player?.pause()
            result(true)
            break;
            
        case "view_created":
            viewCreated()
            break;
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
}
