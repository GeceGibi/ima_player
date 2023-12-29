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


class ImaPlayerView: NSObject, FlutterPlatformView, FlutterStreamHandler, IMAAdsManagerDelegate, IMAAdsLoaderDelegate {
    enum Events: String {
        case ads
        case player
    }
    
    private var avPlayer: AVPlayer!
    
    private var imaAdsLoader: IMAAdsLoader!
    private var imaAdsManager: IMAAdsManager?
    private var avPlayerViewController = AVPlayerViewController()
    
    private var methodChannel: FlutterMethodChannel!
    private var eventChannel: FlutterEventChannel!
    private var eventSink: FlutterEventSink!
    
    private var imaPlayerSettings = ImaPlayerSettings()
    
    private var isDisposed = false
    private var isShowingContent = false
    
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
        super.init()
        
        /// Set settings
        setPlayerSettingsAndInit(args: args)
        
        /// Configure Player Controller
        configurePlayerController(frame: frame)
        
        /// Configure Ads Loader
        configureAdsLoader(args: args)
        
        methodChannel = FlutterMethodChannel(name: "gece.dev/imaplayer/\(viewId)", binaryMessenger: messenger)
        methodChannel.setMethodCallHandler(onMethodCall)
        
        eventChannel = FlutterEventChannel(name: "gece.dev/imaplayer/\(viewId)/events", binaryMessenger: messenger)
        eventChannel.setStreamHandler(self)
        
        avPlayer.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        avPlayer.addObserver(self, forKeyPath: "rate", options: [.initial, .new], context: nil)
    }
    
    func addAvPlayerListener() {
        avPlayer.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        avPlayer.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        avPlayer.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.contentDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem
        );
    }
    
    func configureAdsLoader(args: Dictionary<String, Any>) {
        if !imaPlayerSettings.isAdsEnabled {
            return
        }
        
        let adsLoaderSettings = args["ads_loader_settings"] as! Dictionary<String, Any>
        let loaderSettings  = IMASettings()
        
        loaderSettings.ppid = adsLoaderSettings["ppid"] as? String
        loaderSettings.language = adsLoaderSettings["language"] as! String
        loaderSettings.autoPlayAdBreaks = adsLoaderSettings["auto_play_ad_breaks"] as! Bool
        loaderSettings.enableDebugMode = adsLoaderSettings["enable_debug_mode"] as! Bool
        loaderSettings.enableBackgroundPlayback = true
        
        imaAdsLoader = IMAAdsLoader(settings: loaderSettings)
        imaAdsLoader.delegate = self
    }
    
    func setPlayerSettingsAndInit(args: Dictionary<String, Any>){
        imaPlayerSettings.imaTag = args["ima_tag"] as? String
        imaPlayerSettings.videoUrl = args["video_url"] as? String
        imaPlayerSettings.autoPlay = args["auto_play"] as? Bool ?? false
        imaPlayerSettings.isMuted = args["is_muted"] as? Bool ?? false
        imaPlayerSettings.isMixed = args["is_mixed"] as? Bool ?? true
        imaPlayerSettings.showPlaybackControls = args["show_playback_controls"] as? Bool ?? true
        imaPlayerSettings.isAdsEnabled = args["ads_enabled"] as? Bool ?? true
        
        if imaPlayerSettings.videoUrl != nil {
            avPlayer = AVPlayer(url: URL(string: imaPlayerSettings.videoUrl!)!)
        } else {
            avPlayer = AVPlayer()
        }

        addAvPlayerListener()

        avPlayer.isMuted = imaPlayerSettings.isMuted

    }
    
    func configurePlayerController(frame: CGRect){
        
        avPlayerViewController.player = avPlayer
        avPlayerViewController.view.frame = frame
        
        if #available(iOS 14.2, *) {
            avPlayerViewController.canStartPictureInPictureAutomaticallyFromInline = false
        }
        
        avPlayerViewController.showsPlaybackControls = imaPlayerSettings.showPlaybackControls
        avPlayerViewController.updatesNowPlayingInfoCenter = false
        avPlayerViewController.allowsPictureInPicturePlayback = false
        avPlayerViewController.exitsFullScreenWhenPlaybackEnds = true
        avPlayerViewController.entersFullScreenWhenPlaybackBegins = false
        avPlayerViewController.showsPlaybackControls = imaPlayerSettings.showPlaybackControls
        
        avPlayerViewController.view.isOpaque = true
        avPlayerViewController.view.layer.borderWidth = 0
        avPlayerViewController.view.layer.borderColor = UIColor.clear.cgColor
        avPlayerViewController.view.backgroundColor = UIColor.clear
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        switch (keyPath) {
        case "status":
            if avPlayer.status == .readyToPlay {
                sendEvent(type: .player, value: "READY")
            } else if avPlayer.status == .failed {
                sendEvent(type: .player, value: "FAILED")
            }
            break;
            
        case "rate":
            sendEvent(type: .player, value: avPlayer.rate > 0 ? "PLAYING": "PAUSED")
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
        if imaPlayerSettings.isAdsEnabled {
            imaAdsLoader.contentComplete()
        }
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
        imaAdsManager = adsLoadedData.adsManager
        imaAdsManager!.delegate = self
        
        let settings = IMAAdsRenderingSettings()
        
        settings.enablePreloading = true
        settings.openWebLinksExternally = true
    
        
        imaAdsManager!.initialize(with: settings)
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        if imaPlayerSettings.autoPlay && !isDisposed {
            avPlayer.play()
        }
    }
    
    // MARK: - IMAAdsManagerDelegate
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        sendEvent(type: .ads, value: event.typeString)
        ad = event.ad
        
        if event.type == IMAAdEventType.LOADED && !isDisposed {
            if imaPlayerSettings.isMuted {
                adsManager.volume = 0
            }
            
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        // todo: improve error messages
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        sendEvent(type: .ads, value: "CONTENT_PAUSE_REQUESTED")
        isShowingContent = false
        avPlayer.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        sendEvent(type: .ads, value: "CONTENT_RESUME_REQUESTED")
        isShowingContent = true

        if imaPlayerSettings.autoPlay {
            avPlayer.play()
        }
    }
    
    func requestAds() {
        if imaPlayerSettings.imaTag != nil && !imaPlayerSettings.imaTag!.isEmpty {
            let adDisplayContainer = IMAAdDisplayContainer(
                adContainer: avPlayerViewController.view,
                viewController: avPlayerViewController
            )
         
            let adsRequest = IMAAdsRequest(
                adTagUrl: imaPlayerSettings.imaTag!,
                adDisplayContainer: adDisplayContainer,
                contentPlayhead: nil,
                userContext: nil
            )
            
            imaAdsLoader.requestAds(with: adsRequest)
        }
    }
    
    
    var timer = Timer()
    func viewCreated(result: FlutterResult) {
        result(nil)
        
        if !imaPlayerSettings.isAdsEnabled {
            return
        }
        
        // just in case this button is tapped multiple times
        timer.invalidate()
        
        // start the timer
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(self.checkViewIsReady),
            userInfo: nil,
            repeats: true
        )
    }
    
    
    @objc func checkViewIsReady() {
        if self.avPlayerViewController.view.window != nil {
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
            "ad_current_position": roundForTwo(value: imaAdsManager?.adPlaybackInfo.currentMediaTime ?? 0),
            "ad_height": ad?.vastMediaWidth,
            "ad_width": ad?.vastMediaWidth,
            "ad_type": ad?.contentType,
            "ad_skip_time_offset": roundForTwo(value: ad?.skipTimeOffset),
            
            "is_playing": imaAdsManager?.adPlaybackInfo.isPlaying ?? false,
            "is_buffering": imaAdsManager?.adPlaybackInfo.currentMediaTime != 0,
            "is_skippable": ad?.isSkippable,
            "is_ui_disabled": ad?.isUiDisabled,
            
            "total_ad_count": ad?.adPodInfo.totalAds,
        ]
        
        result(info)
    }
    
    private func getVideoInfo(result: FlutterResult){
        let totalDurationSeconds = avPlayer.currentItem?.duration.seconds ?? 0.0
        let totalSeconds = totalDurationSeconds.isNaN ? 0.0 : totalDurationSeconds
        
        let info: Dictionary<String, Any?> = [
            "current_position": roundForTwo(value: avPlayer.currentItem?.currentTime().seconds),
            "total_duration": Double(String(format: "%.1f", totalSeconds)),
            "is_playing": avPlayer.rate > 0,
            "is_buffering": isBuffering,
            "width": Int(avPlayer.currentItem?.presentationSize.width ?? 0),
            "height": Int(avPlayer.currentItem?.presentationSize.height ?? 0)
        ]
        
        result(info)
    }
    
    
    private func roundForTwo(value: Double? ) -> Double {
        return round((value ?? 0) * 10) / 10.0
    }
    
    private func seekTo(value: Double, result: FlutterResult) {
        let time = CMTimeMakeWithSeconds(Float64(value), preferredTimescale: 1000)
        let canSeek = avPlayer.currentItem != nil && avPlayer.currentItem!.duration > time;
        
        if canSeek {
            avPlayer.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        
        result(canSeek)
    }
    
    private func play(videoUrl: String?, result: FlutterResult) {
        if videoUrl != nil {
            imaPlayerSettings.videoUrl = videoUrl
            let playerItem = AVPlayerItem.init(url: URL(string: videoUrl!)!)
            avPlayer.replaceCurrentItem(with: playerItem)
            addAvPlayerListener()
            requestAds()
        }
        
        if isShowingContent || !imaPlayerSettings.isAdsEnabled {
            avPlayer.play()
        } else {
            imaAdsManager?.resume();
        }
        
        result(nil)
    }
    
    private func pause(result: FlutterResult) {
        if (isShowingContent) {
            avPlayer.pause()
        } else {
            imaAdsManager?.pause()
        }
        
        result(nil)
    }
    
    private func stop(result: FlutterResult){
        avPlayer.seek(to: .zero)
        avPlayer.pause()
        result(nil)
    }
    
    private func setVolume(value: Double, result: FlutterResult) {
        avPlayer.volume = Float(value)
        imaAdsManager?.volume = Float(value)
    
        imaPlayerSettings.isMuted = value == 0
        avPlayer.isMuted = value == 0
        
        result(nil)
    }
    
    private func skipAd(result: FlutterResult){
        if ad?.isSkippable ?? false {
            imaAdsManager?.skip()
        }
        
        result(nil)
    }
    
    private func sendEvent(type: Events, value: Any?) {
        eventSink?([ "type": type.rawValue, "value": value ])
    }
    
    func dispose(result: FlutterResult) {
        isDisposed = true
        
        timer.invalidate()
        
        imaAdsManager?.destroy()
        imaAdsManager = nil
        
        avPlayer.replaceCurrentItem(with: nil)
        avPlayerViewController.player = nil
        avPlayerViewController.removeFromParent()
        
        methodChannel = nil
        eventChannel = nil
        eventSink = nil

        NotificationCenter.default.removeObserver(self)
        
        result(nil)
    }
}
