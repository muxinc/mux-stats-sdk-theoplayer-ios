//
//  ViewController.swift
//  MUXSDKStatsTHEOplayerSPMExample
//

import MuxCore
import MuxStatsTHEOplayer
import THEOplayerSDK
import UIKit

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
            license: "sZP7IYe6T6PlIKhZClxe0ZzLIS5cFSx6Iu0-CKfZ06zt0QPKIKht3SXl3uR6FOPlUY3zWokgbgjNIOf9flCkISai0oBcFSac0LR-3uIK0Ok13lfkFSP63KXl0of_CShZTmfVfK4_bQgZCYxNWoryIQXzImf90SbZ3lho3Lfi0u5i0Oi6Io4pIYP1UQgqWgjeCYxgflEc3leZ0Lbt3Lf_3SBLFOPeWok1dDrLYtA1Ioh6TgV6v6fVfKcqCoXVdQjLUOfVfGxEIDjiWQXrIYfpCoj-fgzVfKxqWDXNWG3ybojkbK3gflNWf6E6FOPVWo31WQ1qbta6FOPzdQ4qbQc1sD4ZFK3qWmPUFOPLIQ-LflNWfKgqbZPUFOPLIDreYog-bwPgbt3NWo_6TGxZUDhVfKIgCYxkbK4LflNWYYz"
        )

        self.player = THEOplayer(
            configuration: playerConfig
        )
        player.addAsSubview(of: playerContainerView)

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

        let typedSource = TypedSource(
            src: "https://stream.mux.com/tqe4KzdxU6GLc8oowshXgm019ibzhEX3k.m3u8",
            type: "application/vnd.apple.mpegurl")

        let ad = THEOAdDescription(src: "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpremidpostpod&cmsid=496&vid=short_onecue&correlator=")

        let source = SourceDescription(source: typedSource, ads: [ad], textTracks: nil, poster: nil, analytics: nil, metadata: nil)
        self.player.source = source

        // TODO: Add your property key!
        let playerData = MUXSDKCustomerPlayerData(
            environmentKey: "qr9665qr78dac0hqld9bjofps"
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
            softwareVersion: "0.8.0"
        )
        self.player.play()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.frame = view.frame
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

