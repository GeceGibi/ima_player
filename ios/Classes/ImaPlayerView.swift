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
    private var adsManager: IMAAdsManager?
    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    private var avPlayerViewController: AVPlayerViewController
    
    private var methodChannel: FlutterMethodChannel!
    private var eventChannel: FlutterEventChannel!
    private var eventSink: FlutterEventSink!
    
    private var imaTag: String?
    private var videoUrl: URL
    private var autoPlay = false
    private var isMuted = false
    private var isMixed = true
    private var showPlaybackControls = true
    
    
    /// Info arguments
    private var isBuffering = false
    private var ad: IMAAd?
    
    func view() -> UIView {
        return avPlayerViewController.view
    }
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Dictionary<String, Any>,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        
        imaTag = args["ima_tag"] as? String
        videoUrl = URL(string: args["video_url"] as? String ?? "")!
        autoPlay = args["auto_play"] as? Bool ?? false
        isMuted = args["is_muted"] as? Bool ?? false
        isMixed = args["is_mixed"] as? Bool ?? true
        showPlaybackControls = args["show_playback_controls"] as? Bool ?? true
        
        avPlayerViewController = AVPlayerViewController()
        
        let settings = IMASettings()
        let adsLoaderSettings = args["ads_loader_settings"] as! Dictionary<String, Any>
        
        settings.ppid = adsLoaderSettings["ppid"] as? String
        settings.language = adsLoaderSettings["language"] as! String
        settings.autoPlayAdBreaks = adsLoaderSettings["auto_play_ad_breaks"] as! Bool
        settings.enableDebugMode = adsLoaderSettings["enable_debug_mode"] as! Bool
        settings.enableBackgroundPlayback = true
        
        adsLoader = IMAAdsLoader(settings: settings)
        
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
        avPlayerViewController.view.isOpaque = true
        avPlayerViewController.updatesNowPlayingInfoCenter = false
        avPlayerViewController.view.layer.borderWidth = 0
        avPlayerViewController.view.layer.borderColor = UIColor.clear.cgColor
        avPlayerViewController.view.backgroundColor = UIColor.clear
        // avPlayerViewController.view.layer.shouldRasterize = true
        
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
        switch (keyPath) {
        case "status":
            if player?.status == .readyToPlay {
                sendEvent(type: .player, value: "READY")
            } else if player?.status == .failed {
                sendEvent(type: .player, value: "FAILED")
            }
            break;
            
        case "rate":
            if player != nil {
                sendEvent(type: .player, value: player.rate > 0 ? "PLAYING": "PAUSED")
            }
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
        adsManager?.delegate = self
        adsManager?.initialize(with: nil)
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        // todo: improve error messages
        if autoPlay {
            player?.play()
        }
    }
    
    // MARK: - IMAAdsManagerDelegate
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        sendEvent(type: .ads, value: event.typeString)
        
        print(event.typeString)
        
        switch event.type {
        case IMAAdEventType.SKIPPED: fallthrough
        case IMAAdEventType.COMPLETE: fallthrough
        case IMAAdEventType.ALL_ADS_COMPLETED:
            ad = nil
            break;
            
        case IMAAdEventType.LOADED:
            adsManager.start()
            break;
            
        default:
            ad = event.ad
            break;
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        // todo: improve error messages
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        if player != nil && player.rate > 0 {
            player.pause()
        }
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        if player.rate == 0 {
            player.play()
        }
    }
    
    func requestAds() {
        if imaTag != nil && !imaTag!.isEmpty {
            let adDisplayContainer = IMAAdDisplayContainer(
                adContainer: avPlayerViewController.view,
                viewController: avPlayerViewController
            )
            
            let request = IMAAdsRequest(
                adTagUrl: imaTag!,
                adDisplayContainer: adDisplayContainer,
                contentPlayhead: contentPlayhead,
                userContext: nil
            )
            
            adsLoader.requestAds(with: request)
        }

    }
    
    
    var timer = Timer()
    func viewCreated(result: FlutterResult){
        // just in case this button is tapped multiple times
        timer.invalidate()
        
        // start the timer
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(checkViewIsReady),
            userInfo: nil,
            repeats: true
        )
        
        result(true)
    }
    
    @objc func checkViewIsReady(){
        if(self.avPlayerViewController.isViewLoaded && (self.avPlayerViewController.view.window != nil)) {
            timer.invalidate()
            self.requestAds()
        }
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
            
        case "get_video_info":
            getVideoInfo(result: result)
            break;
            
        case "get_ad_info":
            getAdInfo(result: result)
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
    
    private func getAdInfo(result: FlutterResult) {
        let info: Dictionary<String, Any?> = [
            "ad_title": ad?.adTitle,
            "ad_duration": roundForTwo(value: ad?.duration),
            "ad_current_position": roundForTwo(value: adsManager?.adPlaybackInfo.currentMediaTime ?? 0),
            "ad_height": ad?.vastMediaWidth,
            "ad_width": ad?.vastMediaWidth,
            "ad_type": ad?.contentType,
            "ad_skip_time_offset": roundForTwo(value: ad?.skipTimeOffset),
            
            "is_playing": adsManager?.adPlaybackInfo.isPlaying ?? false,
            "is_buffering": adsManager?.adPlaybackInfo.currentMediaTime != 0,
            "is_skippable": ad?.isSkippable,
            "is_ui_disabled": ad?.isUiDisabled,
            
            "total_ad_count": ad?.adPodInfo.totalAds,
        ]
        
        result(info)
    }
    
    private func getVideoInfo(result: FlutterResult){
        
        let totalDurationSeconds = player.currentItem?.duration.seconds ?? 0.0
        let totalSeconds = totalDurationSeconds.isNaN ? 0.0 : totalDurationSeconds
        
        let info: Dictionary<String, Any?> = [
            "current_position": roundForTwo(value: player.currentItem?.currentTime().seconds),
            "total_duration": Double(String(format: "%.1f", totalSeconds)),
            "is_playing": player.rate > 0,
            "is_buffering": isBuffering,
            "width": Int(player.currentItem?.presentationSize.width ?? 0),
            "height": Int(player.currentItem?.presentationSize.height ?? 0)
        ]
        
        result(info)
    }
    
    
    private func roundForTwo(value: Double? ) -> Double {
        return round((value ?? 0) * 10) / 10.0
    }
    
    private func seekTo(value: Double, result: FlutterResult) {
        let time = CMTimeMakeWithSeconds(Float64(value), preferredTimescale: 1000)
        let canSeek = player.currentItem != nil && player.currentItem!.duration > time;
        
        if canSeek {
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        
        result(canSeek)
    }
    
    private func play(videoUrl: String?, result: FlutterResult) {
        if videoUrl != nil {
            self.videoUrl = URL(string: videoUrl!)!
            let playerItem = AVPlayerItem.init(url: self.videoUrl)
            player.replaceCurrentItem(with: playerItem)
        }
        
        if ad != nil && adsManager != nil && !adsManager!.adPlaybackInfo.isPlaying {
            if adsManager?.adPlaybackInfo.currentMediaTime == 0 {
                adsManager?.start();
            } else {
                adsManager?.resume();
            }
        } else {
            player?.play()
        }
        
        result(true)
    }
    private func pause(result: FlutterResult) {
        if (adsManager?.adPlaybackInfo.isPlaying ?? false) {
            adsManager?.pause()
        } else {
            player?.pause()
        }
        
        result(true)
    }
    
    private func stop(result: FlutterResult){
        player?.pause()
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
        adsManager?.pause()
        adsManager?.destroy()
        result(true)
    }
    
    private func setVolume(value: Double, result: FlutterResult) {
        player.volume = Float(value)
        result(true)
    }
    
    private func skipAd(result: FlutterResult){
        let isSkippable = (ad?.isSkippable ?? false) && (adsManager?.adPlaybackInfo.isPlaying ?? false)
        
        if isSkippable {
            adsManager?.skip()
        }
        
        result(isSkippable)
    }
    
    private func sendEvent(type: Events, value: Any?) {
        eventSink?([ "type": type.rawValue, "value": value ])
    }
    
    func dispose(result: FlutterResult) {
        timer.invalidate()
        
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
