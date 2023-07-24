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
    enum Events: String {
        case ads
        case player
    }
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer?
    private var adsLoader: IMAAdsLoader
    private var adsManager: IMAAdsManager!
    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    private var avPlayerViewController: AVPlayerViewController
    
    private var methodChannel: FlutterMethodChannel!
    private var eventChannel: FlutterEventChannel!
    private var eventSink: FlutterEventSink!
    
    private var imaTag: String
    private var videoUrl: URL
    private var autoPlay = false
    private var isMuted = false
    private var isMixed = true
    private var showPlaybackControls = true
    
    
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
        videoUrl = URL(string: (args?["video_url"] ?? "") as! String)!
        autoPlay = (args?["auto_play"] ?? false) as! Bool
        isMuted = (args?["is_muted"] ?? false) as! Bool
        isMixed = (args?["is_mixed"] ?? true) as! Bool
        showPlaybackControls = (args?["show_playback_controls"] ?? true) as! Bool
        
        
        avPlayerViewController = AVPlayerViewController()
        adsLoader = IMAAdsLoader(settings: nil)
        
        super.init()
        
        methodChannel = FlutterMethodChannel(name: "gece.dev/imaplayer/\(viewId)", binaryMessenger: messenger)
        methodChannel.setMethodCallHandler(onMethodCall)
        
        eventChannel = FlutterEventChannel(name: "gece.dev/imaplayer/\(viewId)/events", binaryMessenger: messenger)
        eventChannel.setStreamHandler(self)
        
        adsLoader.delegate = self
        
        
        player = AVPlayer(url: videoUrl)
        player.isMuted = isMuted
        
        let audioSession = AVAudioSession.sharedInstance()
        let isMixed = isMixed
        
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
        
        avPlayerViewController.showsPlaybackControls = showPlaybackControls
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
                sendEvent(type: .player, value: "READY")
            } else if player.status == .failed {
                sendEvent(type: .player, value: "FAILED")
            }
            break;
            
        case "rate":
            sendEvent(type: .player, value: player.rate > 0 ? "PLAYING": "PAUSED")
            break;
            
        case "playbackBufferFull": fallthrough
        case "playbackBufferEmpty":
            isBuffering = false
            break;
            
        case "playbackLikelyToKeepUp":
            isBuffering = true
            sendEvent(type: .player, value: "BUFFERING")
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
        sendEvent(type: .ads, value: event.typeString)
        
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
        let adDisplayContainer = IMAAdDisplayContainer(
            adContainer: avPlayerViewController.view,
            viewController: avPlayerViewController
        )
        
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
            play(videoUrl: call.arguments as! String?, result: result)
            break;
            
        case "pause":
            pause(result: result)
            break;
            
        case "stop":
            stop(result: result)
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
            skipAd(result: result)
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
        
        let totalDurationSeconds = player.currentItem?.duration.seconds ?? 0.0
        let totalSeconds = totalDurationSeconds.isNaN ? 0.0 : totalDurationSeconds
        
        
        let info: Dictionary<String, Any> = [
            "current_position": Int(player.currentItem?.currentTime().value ?? 0) / 1000000,
            "total_duration": Int(totalSeconds) * 1000,
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
    
    private func play(videoUrl: String?, result: FlutterResult) {
        if videoUrl != nil {
            self.videoUrl = URL(string: videoUrl!)!
            let playerItem = AVPlayerItem.init(url: self.videoUrl)
            player.replaceCurrentItem(with: playerItem)
        }
        
        player?.play()
        result(true)
    }
    private func pause(result: FlutterResult) {
        player?.pause()
        result(true)
    }
    
    private func stop(result: FlutterResult){
        player?.pause()
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
        result(true)
    }
    
    private func setVolume(value: Double, result: FlutterResult) {
        player.volume = Float(value)
        result(true)
    }
    
    private func skipAd(result: FlutterResult){
        adsManager.skip()
        result(isPlayingAds)
    }
    
    private func sendEvent(type: Events, value: Any?) {
        eventSink?([ "type": type.rawValue, "value": value ])
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
