//
//  Binding.swift
//  TestbedObjc
//
//  Created by Ruslan Sokolov on 7/12/19.
//  Copyright © 2019 Ruslan Sokolov. All rights reserved.
//

import Foundation
import MuxCore
import THEOplayerSDK

internal class Binding: NSObject {
    let name: String
    let software: String
    let softwareVersion: String?
    let automaticErrorTracking: Bool
    fileprivate(set) var player: THEOplayer?

    fileprivate var playListener: EventListener?
    fileprivate var sourceListener: EventListener?
    fileprivate var playingListener: EventListener?
    fileprivate var pauseListener: EventListener?
    fileprivate var timeListener: EventListener?
    fileprivate var seekListener: EventListener?
    fileprivate var seekedListener: EventListener?
    fileprivate var errorListener: EventListener?
    fileprivate var completeListener: EventListener?
    fileprivate var adBreakBeginListener: EventListener?
    fileprivate var adBreakEndListener: EventListener?
    fileprivate var adBeginListener: EventListener?
    fileprivate var adEndListener: EventListener?
    fileprivate var adErrorListener: EventListener?
    fileprivate var presentationChangeListener: EventListener?


    var size: CGSize = .zero
    var lastTrackedSize: CGSize?
    var duration: Double = 0
    var isLive = false
    var adIsActive = false

    fileprivate var adProgress: AdProgress = .started
    var ad: Ad? {
        didSet {
            adProgress = .started
        }
    }

    fileprivate var forceSendAdPlaying: Bool = false

    init(name: String, software: String, softwareVersion: String?, automaticErrorTracking: Bool) {
        self.name = name
        self.software = software
        self.softwareVersion = softwareVersion
        self.automaticErrorTracking = automaticErrorTracking
    }

    func attachPlayer(_ player: THEOplayer) {
        if let _ = self.player {
            self.detachPlayer()
        }
        self.player = player
        addEventListeners()
    }

    func detachPlayer() {
        removeEventListeners()
        self.player = nil
    }

    func resetVideoData() {
        size = .zero
        duration = 0
        isLive = false
    }

    func dispatchEvent<Event: MUXSDKPlaybackEvent>(
        _ type: Event.Type,
        checkVideoData: Bool = false,
        includeAdData: Bool = false,
        error: String? = nil,
        errorCode: String? = nil
    ) {
        if checkVideoData {
            self.checkVideoData()
        }
        
        let event = Event()
        if (includeAdData) {
            event.viewData = self.ad?.viewData
        }
        let name = self.name
        event.playerData = playerData()
        // careful here, we only want to disable MUXSDKErrorEvent
        // ad errors should still be triggered (MUXSDKAdErrorEvent)
        // and we don't want to set the player data code/message for
        // ad errors either
        if (type == MUXSDKErrorEvent.self) {
            if let error = error {
                event.playerData?.playerErrorMessage = error
                event.playerData?.playerErrorCode = errorCode
            }
            if (self.automaticErrorTracking) {
                MUXSDKCore.dispatchEvent(event, forPlayer: name)
            }
        } else {
            MUXSDKCore.dispatchEvent(event, forPlayer: name)
        }
    }

    // This method intentionally bypasses `automaticErrorTracking` setting
    // This method is meant to be used when a developer wants to manually dispatch
    // an error. Most commonly used when `automaticErrorTracking` has been explicitly
    // set to false
    func dispatchError(code: String, message: String) {
        let event = MUXSDKErrorEvent()
        let name = self.name

        event.playerData = playerData()
        event.playerData?.playerErrorCode = code
        event.playerData?.playerErrorMessage = message
        MUXSDKCore.dispatchEvent(event, forPlayer: name)
    }
}

fileprivate extension Binding {
    func playerData() -> MUXSDKPlayerData? {
        let data = MUXSDKPlayerData()
        guard let player = self.player else { return nil }

        data.playerMuxPluginName = Constants.pluginName
        data.playerMuxPluginVersion = Constants.pluginVersion
        data.playerSoftwareName = self.software
        if (self.softwareVersion != nil) {
            data.playerSoftwareVersion = self.softwareVersion
        }
        data.playerLanguageCode = NSLocale.preferredLanguages.first
        data.playerWidth = player.frame.size.width * UIScreen.main.nativeScale as NSNumber
        data.playerHeight = player.frame.size.height * UIScreen.main.nativeScale as NSNumber
        data.playerIsFullscreen = player.frame.equalTo(UIScreen.main.bounds) ? "true" : "false"
        data.playerIsPaused = NSNumber(booleanLiteral: player.paused)
        data.playerPlayheadTime = NSNumber(value: (Int64)(player.currentTime * 1000))
        return data
    }

    func checkVideoData() {
        guard let player = player else { return }
        var updated = false

        let duration = (player.duration ?? 0) * 1000 // convert seconds to ms
        if !self.duration.isEqual(to: duration) {
            self.duration = duration
            updated = true
        }
        if !self.duration.isFinite && player.readyState != .HAVE_NOTHING && !self.isLive {
            self.isLive = true
            updated = true
        }
        let haveValidSizeValue = !self.size.equalTo(.zero)
        let sizeHasChanged = self.lastTrackedSize != nil && !self.size.equalTo(self.lastTrackedSize!)

        if ((haveValidSizeValue && self.lastTrackedSize == nil) || sizeHasChanged) {
            updated = true
        }
        if updated {
            let data = MUXSDKVideoData()
            if haveValidSizeValue {
                self.lastTrackedSize = self.size
                data.videoSourceWidth = NSNumber(value: Double(self.size.width))
                data.videoSourceHeight = NSNumber(value: Double(self.size.height))
            }
            if self.duration > 0 {
                data.videoSourceDuration = NSNumber(value: Double(self.duration))
            }
            if self.isLive {
                data.videoSourceIsLive = self.isLive ? "true" : "false"
            }
            let event = MUXSDKDataEvent()
            event.videoData = data
            MUXSDKCore.dispatchEvent(event, forPlayer: self.name)
        }
    }

    func setSizeDimensions () {
        guard let player = player else { return }
        let size = CGSize(width: player.videoWidth, height: player.videoHeight)
        if !self.size.equalTo(size) {
            self.size = size
        }
    }

    func dispatchVideoData (videoData: MUXSDKVideoData) {
        let event = MUXSDKDataEvent()
        event.videoData = videoData
        MUXSDKCore.dispatchEvent(event, forPlayer: self.name)
    }

    func addEventListeners() {
        guard let player = player else { return }

        playListener = player.addEventListener(type: PlayerEventTypes.PLAY) { (_: PlayEvent) in
            if self.adIsActive {
                self.dispatchEvent(MUXSDKAdPlayEvent.self, checkVideoData: true, includeAdData: true)
                if (self.forceSendAdPlaying) {
                    self.dispatchEvent(MUXSDKAdPlayingEvent.self, checkVideoData: true, includeAdData: true)
                    self.forceSendAdPlaying = false
                }
            } else {
                self.dispatchEvent(MUXSDKPlayEvent.self, checkVideoData: true)
            }
        }

        sourceListener = player.addEventListener(type: PlayerEventTypes.SOURCE_CHANGE) { (evt) in
            let source = evt.source?.sources.first
            if (source != nil) {
                let data = MUXSDKVideoData()
                data.videoSourceUrl = source?.src.absoluteString
                let event = MUXSDKDataEvent()
                event.videoData = data
                MUXSDKCore.dispatchEvent(event, forPlayer: self.name)
            }
        }

        playingListener = player.addEventListener(type: PlayerEventTypes.PLAYING) { (_: PlayingEvent) in
            self.setSizeDimensions()
            if (self.adIsActive) {
                self.dispatchEvent(MUXSDKAdPlayingEvent.self, checkVideoData: true, includeAdData: true)
                self.forceSendAdPlaying = false
            } else {
                self.dispatchEvent(MUXSDKPlayingEvent.self, checkVideoData: true)
            }
        }
        pauseListener = player.addEventListener(type: PlayerEventTypes.PAUSE) { (_: PauseEvent) in
            if (self.adIsActive) {
                self.forceSendAdPlaying = true
                self.dispatchEvent(MUXSDKAdPauseEvent.self, checkVideoData: true, includeAdData: true)
            } else {
                let time = player.currentTime
                if let duration = player.duration, time < duration {
                    self.dispatchEvent(MUXSDKPauseEvent.self, checkVideoData: true)
                }
            }
        }
        timeListener = player.addEventListener(type: PlayerEventTypes.TIME_UPDATE) { (evt: TimeUpdateEvent) in
            let time = evt.currentTime
            if let duration = player.duration {
                if (self.adIsActive) {
                    if time >= duration * 0.25 {
                        if self.adProgress < .firstQuartile {
                            self.dispatchEvent(MUXSDKAdFirstQuartileEvent.self, includeAdData: true)
                            self.adProgress = .firstQuartile
                        }
                    }
                    if time >= duration * 0.5 {
                        if self.adProgress < .midpoint {
                            self.dispatchEvent(MUXSDKAdMidpointEvent.self, includeAdData: true)
                            self.adProgress = .midpoint
                        }
                    }
                    if time >= duration * 0.75 {
                        if self.adProgress < .thirdQuartile {
                            self.dispatchEvent(MUXSDKAdThirdQuartileEvent.self, includeAdData: true)
                            self.adProgress = .thirdQuartile
                        }
                    }
                } else {
                    if time > 0, time < duration {
                        self.dispatchEvent(MUXSDKTimeUpdateEvent.self, checkVideoData: true)
                    }
                }
            }
        }
        seekListener = player.addEventListener(type: PlayerEventTypes.SEEKING) { (_: SeekingEvent) in
            self.dispatchEvent(MUXSDKInternalSeekingEvent.self)
        }
        seekedListener = player.addEventListener(type: PlayerEventTypes.SEEKED) { (_: SeekedEvent) in
            self.dispatchEvent(MUXSDKSeekedEvent.self)
        }
        errorListener = player.addEventListener(type: PlayerEventTypes.ERROR) { (event: ErrorEvent) in
            var errorCode = String(event.errorObject?.code.rawValue ?? 0)
            if (errorCode == "0") {
                errorCode = "Unknown Error Code"
            }
            self.dispatchEvent(MUXSDKErrorEvent.self, checkVideoData: true, error: event.error, errorCode: errorCode)
        }
        completeListener = player.addEventListener(type: PlayerEventTypes.ENDED) { (_: EndedEvent) in
            self.dispatchEvent(MUXSDKViewEndEvent.self, checkVideoData: true)
        }
        presentationChangeListener = player.addEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE) { (_: PresentationModeChangeEvent) in
            self.setSizeDimensions()
            self.dispatchEvent(MUXSDKTimeUpdateEvent.self, checkVideoData: true)
        }
        adBreakBeginListener = player.ads.addEventListener(type: AdsEventTypes.AD_BREAK_BEGIN) { (_: AdBreakBeginEvent) in
            self.adIsActive = true
            self.dispatchEvent(MUXSDKAdBreakStartEvent.self, includeAdData: true)
        }
        adBreakEndListener = player.ads.addEventListener(type: AdsEventTypes.AD_BREAK_END) { (_: AdBreakEndEvent) in
            self.adIsActive = false
            self.dispatchEvent(MUXSDKAdBreakEndEvent.self, includeAdData: true)
            self.ad = nil
        }
        adBeginListener = player.ads.addEventListener(type: AdsEventTypes.AD_BEGIN) { (event: AdBeginEvent) in
            self.ad = event.ad
        }
        adEndListener = player.ads.addEventListener(type: AdsEventTypes.AD_END) { (_: AdEndEvent) in
            self.dispatchEvent(MUXSDKAdEndedEvent.self, includeAdData: true)
            self.ad = nil
        }
        adErrorListener = player.ads.addEventListener(type: AdsEventTypes.AD_ERROR) { (event: AdErrorEvent) in
            self.dispatchEvent(MUXSDKAdErrorEvent.self)
            self.ad = nil
        }
    }

    func removeEventListeners() {
        if let playListener = playListener {
            player?.removeEventListener(type: PlayerEventTypes.PLAY, listener: playListener)
            self.playListener = nil
        }
        if let sourceListener = sourceListener {
            player?.removeEventListener(type: PlayerEventTypes.SOURCE_CHANGE, listener: sourceListener)
            self.sourceListener = nil
        }
        if let playingListener = playingListener {
            player?.removeEventListener(type: PlayerEventTypes.PLAYING, listener: playingListener)
            self.playingListener = nil
        }
        if let pauseListener = pauseListener {
            player?.removeEventListener(type: PlayerEventTypes.PAUSE, listener: pauseListener)
            self.pauseListener = nil
        }
        if let timeListener = timeListener {
            player?.removeEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: timeListener)
            self.timeListener = nil
        }
        if let seekListener = seekListener {
            player?.removeEventListener(type: PlayerEventTypes.SEEKING, listener: seekListener)
            self.seekListener = nil
        }
        if let seekedListener = seekedListener {
            player?.removeEventListener(type: PlayerEventTypes.SEEKED, listener: seekedListener)
            self.seekedListener = nil
        }
        if let errorListener = errorListener {
            player?.removeEventListener(type: PlayerEventTypes.ERROR, listener: errorListener)
            self.errorListener = nil
        }
        if let completeListener = completeListener {
            player?.removeEventListener(type: PlayerEventTypes.ENDED, listener: completeListener)
            self.completeListener = nil
        }
        if let presentationChangeListener = presentationChangeListener {
            player?.removeEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: presentationChangeListener)
            self.presentationChangeListener = nil
        }
        if let adBreakBeginListener = adBreakBeginListener {
            player?.removeEventListener(type: AdsEventTypes.AD_BREAK_BEGIN, listener: adBreakBeginListener)
            self.adBreakBeginListener = nil
        }
        if let adBreakEndListener = adBreakEndListener {
            player?.removeEventListener(type: AdsEventTypes.AD_BREAK_END, listener: adBreakEndListener)
            self.adBreakEndListener = nil
        }
        if let adBeginListener = adBeginListener {
            player?.removeEventListener(type: AdsEventTypes.AD_BEGIN, listener: adBeginListener)
            self.adBeginListener = nil
        }
        if let adEndListener = adEndListener {
            player?.removeEventListener(type: AdsEventTypes.AD_END, listener: adEndListener)
            self.adEndListener = nil
        }
        if let adErrorListener = adErrorListener {
            player?.removeEventListener(type: AdsEventTypes.AD_ERROR, listener: adErrorListener)
            self.adErrorListener = nil
        }
    }
}

fileprivate enum AdProgress: Int, Comparable {
    case started, firstQuartile, midpoint, thirdQuartile

    public static func < (a: AdProgress, b: AdProgress) -> Bool {
        return a.rawValue < b.rawValue
    }
}

fileprivate extension Ad {
    var viewData: MUXSDKViewData {
        let view = MUXSDKViewData()
        view.viewPrerollAdId = id
        view.viewPrerollCreativeId = id
        return view
    }
}
