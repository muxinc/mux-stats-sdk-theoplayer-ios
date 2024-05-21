//
//  ViewController.swift
//  DemoApp
//
//  Created by Ruslan Sokolov on 7/20/19.
//  Copyright © 2019 Mux, Inc. All rights reserved.
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

class ViewController: UIViewController {
    let playerName = "demoplayer"
    var player: THEOplayer!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // THEOplayer object
        self.player = {
            let builder = THEOplayerConfigurationBuilder()
            builder.license = ProcessInfo.processInfo.theoPlayerLicenseKey
            return THEOplayer(
                configuration: builder.build()
            )
        }()
        self.player.frame = view.bounds
        self.player.addAsSubview(of: view)

        let typedSource = TypedSource(
            src: "https://stream.mux.com/tqe4KzdxU6GLc8oowshXgm019ibzhEX3k.m3u8",
            type: "application/vnd.apple.mpegurl"
        )

        let source = SourceDescription(
            source: typedSource
        )
        self.player.source = source

        // TODO: Add your property key!
        let playerData = MUXSDKCustomerPlayerData(environmentKey: "YOUR_ENV_KEY")!

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
            softwareVersion: THEOplayer.version
        )
        self.player.play()

        // Example of changing the video after 60 seconds
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(60)) {
//            let videoData = MUXSDKCustomerVideoData()
//            videoData.videoTitle = "Apple Keynote"
//            videoData.videoId = "applekeynote2010"
//
//            MUXSDKStatsTHEOplayer.videoChangeForPlayer(name: self.playerName, videoData: videoData)
//
//            let typedSource = TypedSource(
//                src: "https://stream.mux.com/tNrV028WTqCOa02zsveBdNwouzgZTbWx5x.m3u8",
//                type: "application/vnd.apple.mpegurl")
//
//            let source = SourceDescription(source: typedSource, ads: [], textTracks: nil, poster: nil, analytics: nil, metadata: nil)
//            self.player.source = source
//            self.player.play()
//        }
    }
}
