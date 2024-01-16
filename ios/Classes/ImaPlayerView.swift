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

class ImaPlayerView: NSObject, FlutterPlatformView, IMAAdsManagerDelegate, IMAAdsLoaderDelegate, FlutterStreamHandler {
    private var viewId: Int64
    private var eventSink: FlutterEventSink?
    private var eventQueue: [Dictionary<String, Any>] = []
    
    private var methodChannel: FlutterMethodChannel
    private var eventChannel: FlutterEventChannel
    
    private var imaPlayerSettings: ImaPlayerSettings!
    private var avPlayer: AVPlayer!
    
    private var imaAdsLoader: IMAAdsLoader!
    private var imaAdsManager: IMAAdsManager?
    private var avPlayerViewController = AVPlayerViewController()
    
    private var isDisposed = false
    private var isShowingContent = true
    
    private var timer: Timer?
    
    func view() -> UIView {
        return avPlayerViewController.view
    }
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Dictionary<String, Any>,
        binaryMessenger messenger: FlutterBinaryMessenger,
        imaSdkSettings: IMASettings,
        imaPlayerSettings: ImaPlayerSettings,
        headers: Dictionary<String, String>,
        methodChannel: FlutterMethodChannel,
        eventChannel: FlutterEventChannel
    ) {
        
        self.viewId = viewId;
        self.eventChannel = eventChannel
        self.methodChannel = methodChannel
        self.imaPlayerSettings = imaPlayerSettings
        
        avPlayer = AVPlayer(url: imaPlayerSettings.uri)
        avPlayer.volume = Float(imaPlayerSettings.initialVolume)
        
        avPlayerViewController.player = avPlayer
        avPlayerViewController.view.frame = frame
        avPlayerViewController.showsPlaybackControls = imaPlayerSettings.showPlaybackControls
        avPlayerViewController.updatesNowPlayingInfoCenter = false
        avPlayerViewController.allowsPictureInPicturePlayback = false
        
        if #available(iOS 16.0, *) {
            avPlayerViewController.allowsVideoFrameAnalysis = false
        }
        
        super.init()
        
        eventChannel.setStreamHandler(self);
        methodChannel.setMethodCallHandler(onMethodCall)
        
        setMixWithOther()
        addListenerForItem()
        addListenerForPlayer()
        
        /// Configure Ads Loader
        if imaPlayerSettings.isAdsEnabled {
            imaAdsLoader = IMAAdsLoader(settings: imaSdkSettings)
            imaAdsLoader.delegate = self
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            if !self.avPlayerViewController.isViewLoaded || self.avPlayerViewController.view.window == nil {
                return
            }
            
            timer.invalidate()
            self.requestAd()
        }
    }
    
    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch(call.method){
        case "play":
            play(uri: call.arguments as! String?, result: result)
            break;
            
        case "pause":
            pause(result: result)
            break;
            
        case "stop":
            stop(result: result)
            break;
            
        case "seek_to":
            seekTo(value: call.arguments as! Double, result: result)
            break;
            
        case "set_volume":
            setVolume(value: call.arguments as! Double, result: result)
            break;
            
        case "current_position":
            getCurrentPosition(result: result)
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
    
    func addListenerForPlayer() {
        avPlayer.addObserver(self, forKeyPath: "volume", options: [.new], context: nil)
        avPlayer.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        avPlayer.addObserver(self, forKeyPath: "rate", options: [.initial, .new], context: nil)
    }
    
    func addListenerForItem() {
        avPlayer.currentItem?.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        avPlayer.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        avPlayer.currentItem?.addObserver(self, forKeyPath: "presentationSize", options: .new, context: nil)
        avPlayer.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.contentDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem
        );
    }
    
    func setMixWithOther() {
        #if os(iOS)
        if imaPlayerSettings.isMixed {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: .mixWithOthers)
        } else {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        }
        #endif
    }
    
    override func observeValue(forKeyPath keyPath: String?,  of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if isDisposed {
            return
        }
        
        switch (keyPath) {
        case "status":
            if avPlayer.status == .readyToPlay {
                sendEvent(event: ["type": "ready"])
                
                if !imaPlayerSettings.isAdsEnabled && imaPlayerSettings.autoPlay && avPlayer.rate == 0 {
                    avPlayer.play()
                }
                
            } else if avPlayer.status == .failed {
                // sendEvent(value: ["player_error": avPlayer.error])
            }
            break;
            
        case "rate":
            sendEvent(event: ["type": avPlayer.rate > 0 ? "playing": "paused"])
            break;
            
        case "volume":
            sendEvent(event: ["type": "volume", "volume": avPlayer.volume])
            break;
            
        case "playbackLikelyToKeepUp":
            if (avPlayer.currentItem?.isPlaybackLikelyToKeepUp ?? false) {
                sendEvent(event: ["type": "buffering_end"])
            } else {
                sendEvent(event: ["type": "buffering_start"])
            }
            break;
            
        case "duration":
            if (avPlayer.currentItem?.duration != nil) {
                sendEvent(event: [
                    "type": "duration",
                    "value": timeToMillis(avPlayer.currentItem!.duration)
                ])
            }
            break;
            
        case "loadedTimeRanges":
            if let loadedTimeRanges = avPlayer.currentItem?.loadedTimeRanges.first as? CMTimeRange {
                sendEvent(event: [
                    "type": "buffered_duration",
                    "duration": timeToMillis(loadedTimeRanges.start + loadedTimeRanges.duration)
                ])
            }
            break;
            
        case "presentationSize":
            let size = [avPlayer.currentItem!.presentationSize.width, avPlayer.currentItem!.presentationSize.height]
            sendEvent(event: ["type": "size_changed", "size": size])
            break;
            
            
        case .none: fallthrough
        case .some(_): break
            // no-op
        }
    }
    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
        sendEvent(event: ["type": "ended"])
        
        if imaPlayerSettings.isAdsEnabled {
            imaAdsLoader.contentComplete()
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        while !eventQueue.isEmpty {
            eventSink(eventQueue.removeFirst())
        }
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
        imaAdsManager!.volume = Float(imaPlayerSettings.initialVolume)
        
        let settings = IMAAdsRenderingSettings()
        
        settings.enablePreloading = true
        settings.openWebLinksExternally = true
        imaAdsManager!.initialize(with: settings)
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        if isDisposed {
            return
        }
        
        if imaPlayerSettings.autoPlay{
            avPlayer.play()
        }
    }
    
    // MARK: - IMAAdsManagerDelegate
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
  
        var data = Dictionary<String, Any>()
        data["type"] = "ad_event"
        data["value"] = event.typeString.lowercased()
        sendEvent(event: data)
    
        if event.type == .LOADED {
            let info: [String: Any] = [
                "duration": event.ad?.duration as Any,
                "ad_id": event.ad?.adId as Any,
                "size": [event.ad?.vastMediaWidth, event.ad?.vastMediaHeight],
                "advertiser_name" : event.ad?.advertiserName as Any,
                "ad_system" : event.ad?.adSystem  as Any,
                "content_type" : event.ad?.contentType as Any,
                "description" : event.ad?.adDescription as Any,
                "bitrate" : event.ad?.vastMediaBitrate as Any,
                "title" : event.ad?.adTitle as Any,
                "skippable" : event.ad?.isSkippable as Any,
                "linear" : event.ad?.isLinear as Any,
                "ui_disabled" : event.ad?.isUiDisabled as Any,
                "skip_time_offset" : event.ad?.skipTimeOffset as Any,
                "is_bumper": event.ad?.adPodInfo.isBumper as Any,
                "total_ads": event.ad?.adPodInfo.totalAds as Any
            ]
            
            sendEvent(event: ["type": "ad_info", "info": info])
        } else if event.type == .STARTED {
            if !imaPlayerSettings.autoPlay {
                adsManager.pause()
            }
        }
        
        if event.type == IMAAdEventType.LOADED && !isDisposed {
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        // todo: improve error messages
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        sendEvent(event: ["type": "ad_event", "value": "content_pause_requested"])
        isShowingContent = false
        avPlayer.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        sendEvent(event: ["type": "ad_event", "value": "content_resume_requested"])
        isShowingContent = true
        avPlayer.play()
    }
    
    func requestAd() {
        if imaPlayerSettings.isAdsEnabled {
            let adDisplayContainer = IMAAdDisplayContainer(
                adContainer: avPlayerViewController.view,
                viewController: avPlayerViewController
            )
            
            let adsRequest = IMAAdsRequest(
                adTagUrl: imaPlayerSettings.tag!,
                adDisplayContainer: adDisplayContainer,
                contentPlayhead: nil,
                userContext: nil
            )
            
            imaAdsLoader.requestAds(with: adsRequest)
        }
    }
   
    private func getCurrentPosition(result: FlutterResult) {
        if isDisposed {
            return
        }
        
        if isShowingContent {
            if avPlayer.currentItem != nil {
                result(timeToMillis(avPlayer.currentItem!.currentTime()))
            }
        } else if imaAdsManager != nil {
            result(Int64(imaAdsManager!.adPlaybackInfo.currentMediaTime * 1000))
        } else {
            result(0)
        }
    }
    
    private func seekTo(value: Double, result: FlutterResult) {
        if isDisposed {
            return
        }
        
        let time = CMTimeMakeWithSeconds(Float64(value), preferredTimescale: 1000)
        let canSeek = avPlayer.currentItem != nil && avPlayer.currentItem!.duration > time;
        
        if canSeek {
            avPlayer.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        
        result(canSeek)
    }
    
    private func play(uri: String?, result: FlutterResult) {
        if isDisposed {
            return
        }
        
        if uri != nil {
            imaPlayerSettings.uri = URL(string: uri!)
            let playerItem = AVPlayerItem.init(url: URL(string: uri!)!)
            avPlayer.replaceCurrentItem(with: playerItem)
            addListenerForItem()
        }
        
        if isShowingContent {
            avPlayer.play()
        } else {
            imaAdsManager?.resume()
        }
        
        result(nil)
    }
    
    private func pause(result: FlutterResult) {
        if isDisposed {
            return
        }
        
        avPlayer.pause()
        imaAdsManager?.pause()
        result(nil)
    }
    
    private func stop(result: FlutterResult) {
        if isDisposed {
            return
        }
        
        avPlayer.replaceCurrentItem(with: nil)
        result(nil)
    }
    
    private func setVolume(value: Double, result: FlutterResult) {
        if isDisposed {
            return
        }
        
        avPlayer.volume = Float(value)
        imaAdsManager?.volume = Float(value)
        result(nil)
    }
    
    private func skipAd(result: FlutterResult) {
        if isDisposed {
            return
        }
        
        imaAdsManager?.skip()
        result(nil)
    }
    
    private func sendEvent(event: Dictionary<String, Any>) {
        if isDisposed {
            return
        }
    
        if eventSink == nil {
            eventQueue.append(event)
        } else {
            eventSink!(event)
        }
    }
    
    var TIME_UNSET = -9223372036854775807;
    func timeToMillis(_ time: CMTime) -> Int64 {
        if CMTIME_IS_INDEFINITE(time) {
            return Int64(TIME_UNSET)
        }
        
        if time.timescale == 0 {
            return 0
        }
        
        return Int64(time.value) * 1000 / Int64(time.timescale)
    }
    
    public func dispose(result: FlutterResult) {
        if timer != nil && timer!.isValid {
            timer?.invalidate()
            timer = nil
        }

        imaAdsManager?.destroy()
        imaAdsManager = nil
    
        avPlayer?.replaceCurrentItem(with: nil)
        avPlayer = nil
        avPlayerViewController.player = nil
        avPlayerViewController.removeFromParent()

        eventSink = nil
        eventChannel.setStreamHandler(nil)
        methodChannel.setMethodCallHandler(nil)
        
        NotificationCenter.default.removeObserver(self)
        
        isDisposed = true
        result(nil)
    }
}
