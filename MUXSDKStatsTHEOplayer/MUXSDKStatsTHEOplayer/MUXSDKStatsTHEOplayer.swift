//
//  MuxTHEOplayerSDK.swift
//  TestbedObjc
//
//  Created by Ruslan Sokolov on 7/11/19.
//  Copyright © 2019 Ruslan Sokolov. All rights reserved.
//

import Foundation
import MuxCore
import THEOplayerSDK

@objc public class MUXSDKStatsTHEOplayer: NSObject {
    static var bindings: [String: Binding] = [:]

    /**
     Starts to monitor a given THEOplayer object.

     Use this method to start a Mux player monitor on the given THEoplayer object. The player must have a name which is globally unique. The config provided should match the specifications in the Mux docs at https://docs.mux.com

     - Parameters:
        - _: A player object to monitor
        - name: A name for this instance of the player
        - playerData A MUXSDKCustomerPlayerData object with player metadata
        - videoData A MUXSDKCustomerVideoData object with video metadata
     */
    @objc public static func monitorTHEOplayer(
        _ player: THEOplayer, name: String,
        playerData: MUXSDKCustomerPlayerData, videoData: MUXSDKCustomerVideoData) {
        initSDK()

        if bindings.keys.contains(name) {
            destroyPlayer(name: name)
        }

        let binding = Binding(name: name, software: Constants.software) //, delegate: delegate)
        binding.attachPlayer(player)
        bindings[name] = binding

        binding.dispatchEvent(MUXSDKViewInitEvent.self)
        dispatchDataEvent(playerName: name, playerData: playerData, videoData: videoData)
        binding.dispatchEvent(MUXSDKPlayerReadyEvent.self)
    }


    /**
     Signals that a player is now playing a different video.

     Use this method to signal that the player is now playing a new video. The player name provided must been passed as the name in a monitorTHEOplayer(_:, name:, playerData:, videoData:) call. If the name of the player provided was not previously initialized, no action will be taken.

     - Parameters:
         - name: The name of the player to update
         - playerData A MUXSDKCustomerPlayerData object with player metadata
         - videoData A MUXSDKCustomerVideoData object with video metadata
     */
    @objc public static func videoChangeForPlayer(name: String, videoData: MUXSDKCustomerVideoData) {
        guard let player = bindings[name] else { return }

        player.dispatchEvent(MUXSDKViewEndEvent.self, checkVideoData: true)
        player.resetVideoData()
        player.dispatchEvent(MUXSDKViewInitEvent.self)

        let event = MUXSDKDataEvent()
        event.customerVideoData = videoData
        event.videoChange = true
        MUXSDKCore.dispatchEvent(event, forPlayer: name)
    }

    /**
     Removes any AVPlayer observers on the associated player.

     When you are done with a player, call destoryPlayer(name:) to remove all observers that were set up when monitorTHEOplayer(_:, name:, playerData:, videoData:) was called and to ensure that any remaining tracking pings are sent to complete the view. If the name of the player provided was not previously initialized, no action will be taken.

     - Parameters:
         - name: The name of the player to destroy
     */
    @objc public static func destroyPlayer(name: String) {
        if let binding = bindings.removeValue(forKey: name) {
            binding.detachPlayer()
        }
    }
}

fileprivate extension MUXSDKStatsTHEOplayer {
    static func initSDK() {
        let env = MUXSDKEnvironmentData()
        env.muxViewerId = UIDevice.current.identifierForVendor?.uuidString

        let viewer = MUXSDKViewerData()
        viewer.viewerApplicationName = Bundle.main.bundleIdentifier

        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        if let shortVersion = shortVersion, let version = version {
            viewer.viewerApplicationVersion = "\(shortVersion) (\(version))"
        } else {
            viewer.viewerApplicationVersion = shortVersion ?? version
        }

        viewer.viewerDeviceManufacturer = "Apple"

        let name = UnsafeMutablePointer<utsname>.allocate(capacity: 1)
        uname(name)
        let machine = withUnsafePointer(to: &name.pointee.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        name.deallocate()
        viewer.viewerDeviceName = machine

        let category: String, os: String
        switch UIDevice.current.userInterfaceIdiom {
        case .tv:
            category = "tv"
            os = "tvOS"
        case .pad:
            category = "tablet"
            os = "iOS"
        case .phone:
            category = "phone"
            os = "iOS"
        case .carPlay:
            category = "car"
            os = "CarPlay"
        default:
            category = "unknown"
            os = "unknown"
        }
        viewer.viewerDeviceCategory = category
        viewer.viewerOsFamily = os
        viewer.viewerOsVersion = UIDevice.current.systemVersion

        let event = MUXSDKDataEvent()
        event.environmentData = env
        event.viewerData = viewer
        MUXSDKCore.dispatchGlobalDataEvent(event)
    }

    static func dispatchDataEvent(
        playerName: String, playerData: MUXSDKCustomerPlayerData, videoData: MUXSDKCustomerVideoData) {
        let event = MUXSDKDataEvent()
        event.customerPlayerData = playerData
        event.customerVideoData = videoData
        MUXSDKCore.dispatchEvent(event, forPlayer: playerName)
    }
}

