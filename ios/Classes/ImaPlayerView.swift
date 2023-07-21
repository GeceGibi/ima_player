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
    private var playerLayer: AVPlayerLayer?
    private var adsLoader = IMAAdsLoader(settings: nil)
    private var adsManager: IMAAdsManager!
    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    private var avPlayerViewController = AVPlayerViewController()
    
    private var methodChannel: FlutterMethodChannel!
    
    private var eventChannel: FlutterEventChannel!
    private var eventSink: FlutterEventSink!
    
    private var eventChannelAds: FlutterEventChannel!
    private var eventSinkAds: FlutterEventSink!
    
    private var autoPlay = false
    
    private let imaTag: String
    private let videoUrl: String
    
    func view() -> UIView {
        return avPlayerViewController.view
    }
    
    func dispose(){
        print("dispose - working")
        player.replaceCurrentItem(with: nil)
        avPlayerViewController.player = nil
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)


    }
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Dictionary<String, Any>?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        imaTag = (args?["ima_tag"] ?? "") as! String
        videoUrl = (args?["video_url"] ?? "") as! String
        autoPlay = (args?["auto_play"] ?? false) as! Bool
        
        super.init()
        methodChannel = FlutterMethodChannel(name: "gece.dev/imaplayer/\(viewId)", binaryMessenger: messenger)
        methodChannel.setMethodCallHandler(onMethodCall)
        
        eventChannel = FlutterEventChannel(name: "gece.dev/imaplayer/\(viewId)/events", binaryMessenger: messenger)
        eventChannel.setStreamHandler(self)
        
        adsLoader.delegate = self
        
        // Load AVPlayer with path to your content.
        let contentURL = URL(string: videoUrl)!
        
        player = AVPlayer(url: contentURL)
        
        player.isMuted = (args?["is_muted"] ?? false) as! Bool
        
        let audioSession = AVAudioSession.sharedInstance()
        let isMixed = (args?["is_mixed"] ?? true) as! Bool
        
        do {
            if (isMixed){
                try audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
            } else {
                try audioSession.setCategory(AVAudioSession.Category.playback)
            }
        } catch _{
            
        }
        
        avPlayerViewController.player = player
        
        player.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        player.addObserver(self, forKeyPath: "rate", options: [.initial, .old, .new], context: nil)
        
        playerLayer = AVPlayerLayer.init(player: player)
        avPlayerViewController.view.layer.addSublayer(playerLayer!)
        avPlayerViewController.view.frame = frame
        
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.contentDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        );
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if keyPath == "status" && player.status == .readyToPlay {
            sendEvent(type: "player", value: "READY")
        } else  if keyPath == "rate" {
            sendEvent(type: "player", value: player.rate > 0 ? "PLAYING": "PAUSED")
        }
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
        sendEvent(type: "ads", value: event.typeString)
        
        // Play each ad once it has been loaded
        if event.type == IMAAdEventType.LOADED {
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {}
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        if player.rate > 0 {
            player.pause()
        }
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        if autoPlay && player.rate == 0{
            player.play()
        }
    }
    
    func requestAds() {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: avPlayerViewController.view, viewController: avPlayerViewController)
        let request = IMAAdsRequest(
            adTagUrl: imaTag,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil
        )
        
        adsLoader.requestAds(with: request)
    }
    
    func viewCreated(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
            
        case "get_size":
            sendSize(result: result)
            break;
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getSize() -> Dictionary<String, Int> {
        let size = avPlayerViewController.player?.currentItem?.tracks.first?.assetTrack?.naturalSize
        return ["width": Int(size?.width ?? 0) , "height": Int(size?.height ?? 0)]
    }
    
    private func sendSize(result: FlutterResult){
         result(getSize())
    }
    
    private func sendEvent(type: String, value: Any?) {
        eventSink?([ "type": type, "value": value ])
    }
    
}
