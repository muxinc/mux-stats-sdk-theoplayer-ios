//
//  ViewController.swift
//  MUXSDKStatsTHEOplayerSPMExample
//

import MuxCore
import MuxStatsTHEOplayer
import THEOplayerSDK
import UIKit

extension ProcessInfo {
    var theoPlayerLicenseKey: String {
        environment["THEOPLAYER_LICENSE_KEY"] ?? ""
    }

    var environmentKey: String {
        environment["MUX_ENVIRONMENT_KEY"] ?? ""
    }
}

class PlayerViewController: UIViewController {

    var playerContainerView: UIView!

    let playerName = "exampleplayer"

    // THEOplayer object
    var player: THEOplayer!

    // Dictionary of player event listeners
    var listeners: [String: EventListener] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        playerContainerView = UIView()
        playerContainerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(playerContainerView)
        view.addConstraints(
            [
                view.leadingAnchor.constraint(
                    equalTo: playerContainerView.leadingAnchor
                ),
                view.trailingAnchor.constraint(
                    equalTo: playerContainerView.trailingAnchor
                ),
                view.topAnchor.constraint(
                    equalTo: playerContainerView.topAnchor
                ),
                view.bottomAnchor.constraint(
                    equalTo: playerContainerView.bottomAnchor
                )
            ]
        )

        let playerConfig = THEOplayerConfiguration(
            pip: nil,
            license: ProcessInfo.processInfo.theoPlayerLicenseKey
        )

        self.player = THEOplayer(
            configuration: playerConfig
        )
        player.addAsSubview(of: playerContainerView)

        let typedSource = TypedSource(
            src: "https://stream.mux.com/tqe4KzdxU6GLc8oowshXgm019ibzhEX3k.m3u8",
            type: "application/vnd.apple.mpegurl"
        )

        let source = SourceDescription(
            source: typedSource
        )
        self.player.source = source

        // TODO: Add your property key!
        let playerData = MUXSDKCustomerPlayerData(
            environmentKey: ProcessInfo.processInfo.environmentKey
        )!

        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "Big Buck Bunny"
        videoData.videoId = "bigbuckbunny"
        videoData.videoSeries = "animation"

        let customData = MUXSDKCustomData()
        customData.customData1 = "Theo Player Demo"
        customData.customData2 = "Custom Dimension 2"

        let customerData = MUXSDKCustomerData()
        customerData.customerPlayerData = playerData
        customerData.customerVideoData = videoData
        customerData.customData = customData

        MUXSDKStatsTHEOplayer.monitorTHEOplayer(
            self.player,
            name: playerName,
            customerData: customerData,
            softwareVersion: "0.9.0"
        )
        self.player.play()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.frame = view.frame

        listeners["play"] = player.addEventListener(
            type: PlayerEventTypes.PLAY,
            listener: onPlay(event:)
        )
        listeners["playing"] = player.addEventListener(
            type: PlayerEventTypes.PLAYING,
            listener: onPlaying(event:)
        )
        listeners["pause"] = player.addEventListener(
            type: PlayerEventTypes.PAUSE,
            listener: onPause(event:)
        )
        listeners["ended"] = player.addEventListener(
            type: PlayerEventTypes.ENDED,
            listener: onEnded(event:)
        )
        listeners["error"] = player.addEventListener(
            type: PlayerEventTypes.ERROR,
            listener: onError(event:)
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        player.removeEventListener(
            type: PlayerEventTypes.PLAY,
            listener: listeners["play"]!
        )
        player.removeEventListener(
            type: PlayerEventTypes.PLAYING,
            listener: listeners["playing"]!
        )
        player.removeEventListener(
            type: PlayerEventTypes.PAUSE,
            listener: listeners["pause"]!
        )
        player.removeEventListener(
            type: PlayerEventTypes.ENDED,
            listener: listeners["ended"]!
        )
        player.removeEventListener(
            type: PlayerEventTypes.ERROR,
            listener: listeners["error"]!
        )
        listeners.removeAll()

        super.viewWillDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        player.frame = playerContainerView.frame
    }

    private func onPlay(event: PlayEvent) {
        print("PLAY event, currentTime: %f", event.currentTime)
    }

    private func onPlaying(event: PlayingEvent) {
        print("PLAYING event, currentTime: %f", event.currentTime)
    }

    private func onPause(event: PauseEvent) {
        print("PAUSE event, currentTime: %f", event.currentTime)
    }

    private func onEnded(event: EndedEvent) {
        print("ENDED event, currentTime: %f", event.currentTime)
    }

    private func onError(event: ErrorEvent) {
        print("ERROR event, error: %@", event.error)
    }
}

