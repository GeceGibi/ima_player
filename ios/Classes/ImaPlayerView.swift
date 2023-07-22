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
    private var adsLoader: IMAAdsLoader
    private var adsManager: IMAAdsManager!
    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    private var avPlayerViewController: AVPlayerViewController
    
    private var methodChannel: FlutterMethodChannel!
    private var eventChannel: FlutterEventChannel!
    private var eventSink: FlutterEventSink!
    
    private var autoPlay = false
    
    private let imaTag: String
    private let videoUrl: String
    
    
    /// Info arguments
    private var isBuffering = false
    private var isPlayingAds = false
    
    func view() -> UIView {
        return avPlayerViewController.view
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
        
        
        avPlayerViewController = AVPlayerViewController()
        adsLoader = IMAAdsLoader(settings: nil)
        
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
        
        player.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        player.addObserver(self, forKeyPath: "rate", options: [.initial, .new], context: nil)
        player.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        player.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        player.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        
        
        avPlayerViewController.player = player
        playerLayer = AVPlayerLayer.init(player: player)
   
        avPlayerViewController.showsPlaybackControls = (args?["show_playback_controls"] ?? true) as! Bool
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
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        switch(keyPath){
        case "status":
            if player.status == .readyToPlay {
                sendEvent(type: "player", value: "READY")
            }
            break;
            
        case "rate":
            sendEvent(type: "player", value: player.rate > 0 ? "PLAYING": "PAUSED")
            break;
            
        case "playbackBufferFull": fallthrough
        case "playbackBufferEmpty":
            isBuffering = false
            break;
            
        case "playbackLikelyToKeepUp":
            isBuffering = true
            sendEvent(type: "player", value: "BUFFERING")
            break;
            
            
        case .none: fallthrough
        case .some(_): break
            // no-op
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
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        if autoPlay && player.rate == 0{
            player.play()
        }
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        isPlayingAds = true
        if player.rate > 0 {
            player.pause()
        }
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        isPlayingAds = false
        if autoPlay && player.rate == 0 {
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
    
    func viewCreated(result: FlutterResult){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.requestAds()
        }
        
        result(true)
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
            viewCreated(result: result)
            break;
            
        case "seek_to":
            seekTo(value: call.arguments as! Double, result: result)
            break;
            
        case "set_volume":
            setVolume(value: call.arguments as! Double, result: result)
            break;
            
        case "get_size":
            getSize(result: result)
            break;
            
        case "get_info":
            getInfo(result: result)
            break;
            
        case "dispose":
            dispose(result: result)
            break;
            
        case "skip_ad":
            adsManager.skip()
            result(isPlayingAds)
            break;
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getSize(result: FlutterResult) {
        let size = avPlayerViewController.player?.currentItem?.tracks.first?.assetTrack?.naturalSize
        result(["width": Int(size?.width ?? 0) , "height": Int(size?.height ?? 0)])
    }
    
    private func getInfo(result: FlutterResult){
        let info: Dictionary<String, Any> = [
            "current_position": Int(player.currentItem?.currentTime().value ?? 0) / 1000000,
            "total_duration": Int(player.currentItem?.duration.seconds ?? 0) * 1000,
            "is_playing": player.rate > 0,
            "is_playing_ad": isPlayingAds,
            "is_buffering": isBuffering,
        ]
        
        result(info)
    }
    
    private func seekTo(value: Double, result: FlutterResult) {
        let time = CMTimeMakeWithSeconds(Float64(value), preferredTimescale: 1000)
        let canSeek = player.currentItem != nil && player.currentItem!.duration > time;
        
        if canSeek {
            player.seek(to: time, toleranceBefore:.zero, toleranceAfter: .zero)
        }
        
        result(canSeek)
    }
    
    private func setVolume(value: Double, result: FlutterResult) {
        player.volume = Float(value)
        result(true)
    }
    
    private func sendEvent(type: String, value: Any?) {
        eventSink?([ "type": type, "value": value ])
    }
    
    func dispose(result: FlutterResult) {
        adsManager?.destroy()
        adsManager = nil
        
        player? .replaceCurrentItem(with: nil)
        player = nil
        
        avPlayerViewController.player = nil
        
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        methodChannel = nil
        eventChannel = nil
        eventSink = nil
        
        NotificationCenter.default.removeObserver(self)
        result(true)
    }
    
}
