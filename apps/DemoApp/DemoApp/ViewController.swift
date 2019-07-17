//
//  ViewController.swift
//  DemoApp
//
//  Created by Ruslan Sokolov on 7/20/19.
//  Copyright © 2019 Mux, Inc. All rights reserved.
//

import MuxCore
import MUXSDKStatsTHEOplayer
import THEOplayerSDK
import UIKit

class ViewController: UIViewController {
    let playerName = "demoplayer"
    var player: THEOplayer!

    override func viewDidAppear(_ animated: Bool) {
        self.player = THEOplayer(configuration: THEOplayerConfiguration(chromeless: false))
        self.player.frame = view.bounds
        self.player.addAsSubview(of: view)

        let typedSource = TypedSource(
            src: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
            type: "application/vnd.apple.mpegurl")

        let ad = THEOAdDescription(src: "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpremidpostpod&cmsid=496&vid=short_onecue&correlator=")

        let source = SourceDescription(source: typedSource, ads: [ad], textTracks: nil, poster: nil, analytics: nil, metadata: nil)
        self.player.source = source
        
        // TODO: Add your property key!
        let playerData = MUXSDKCustomerPlayerData(environmentKey: "YOUR_ENVIRONMENT_KEY")!

        let videoData = MUXSDKCustomerVideoData()
        videoData.videoTitle = "Big Buck Bunny"
        videoData.videoId = "bigbuckbunny"
        videoData.videoSeries = "animation"

        MUXSDKStatsTHEOplayer.monitorTHEOplayer(self.player, name: playerName, playerData: playerData, videoData: videoData)
        self.player.play()

        // After 20 seconds, we'll change the video.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20)) {
            let videoData = MUXSDKCustomerVideoData()
            videoData.videoTitle = "Apple Keynote"
            videoData.videoId = "applekeynote2010"

            MUXSDKStatsTHEOplayer.videoChangeForPlayer(name: self.playerName, videoData: videoData)

            let typedSource = TypedSource(
                src: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8",
                type: "application/vnd.apple.mpegurl")

            let source = SourceDescription(source: typedSource, ads: [], textTracks: nil, poster: nil, analytics: nil, metadata: nil)
            self.player.source = source
            self.player.play()
        }
    }
}
