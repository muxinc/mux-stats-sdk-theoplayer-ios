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

public class MUXSDKStatsTHEOplayer: NSObject {
    static var bindings: [String: Binding] = [:]
    
    // Customer Data Store
    static let customerDataStore = MUXSDKCustomerDataStore()
    
    /**
     Starts to monitor a given THEOplayer object.

     Use this method to start a Mux player monitor on the given THEoplayer object. The player must have a name which is globally unique. The config provided should match the specifications in the Mux docs at https://docs.mux.com

     - Parameters:
        - _: A player object to monitor
        - name: A name for this instance of the player
        - customerData: A MUXSDKCustomerData object with player, video, view and custom metadata
        - softwareVersion Optional string to specify the software version metadata
        - automaticErrorTracking Boolean that will enable or disable automatic error tracking. If you use this you will need to use theMUXSDKStatsTHEOplayer  dispatchError method to track fatal errors manually. (default is true)
     */
    public static func monitorTHEOplayer(
        _ player: THEOplayer,
        name: String,
        customerData: MUXSDKCustomerData,
        softwareVersion: String? = nil,
        automaticErrorTracking: Bool = true
    ) {
        initSDK()

        if bindings.keys.contains(name) {
            destroyPlayer(name: name)
        }

        let binding = Binding(name: name, software: Constants.software, softwareVersion: softwareVersion, automaticErrorTracking: automaticErrorTracking)
        binding.attachPlayer(player)
        bindings[name] = binding

        // This MUXSDKViewInitEvent has to be sent synchronously, or anything in
        // the data event may be blown away by the ViewInit coming in after the DataEvent.
        let event = MUXSDKViewInitEvent()
        MUXSDKCore.dispatchEvent(event, forPlayer: name)
        
        customerDataStore.setData(customerData, forPlayerName: name)
        dispatchDataEvent(playerName: name, customerData: customerData, videoChange: false)
        binding.dispatchEvent(MUXSDKPlayerReadyEvent.self)
    }

    /**
     Starts to monitor a given THEOplayer object.

     Use this method to start a Mux player monitor on the given THEoplayer object. The player must have a name which is globally unique. The config provided should match the specifications in the Mux docs at https://docs.mux.com

     - Parameters:
        - _: A player object to monitor
        - name: A name for this instance of the player
        - playerData A MUXSDKCustomerPlayerData object with player metadata
        - videoData A MUXSDKCustomerVideoData object with video metadata
        - softwareVersion Optional string to specify the software version metadata
        - automaticErrorTracking Boolean that will enable or disable automatic error tracking. If you use this you will need to use theMUXSDKStatsTHEOplayer  dispatchError method to track fatal errors manually. (default is true)
     */
    @available(*, deprecated, message: "Please migrate to monitorTHEOplayer:name:customerData:softwareVersion:automaticErrorTracking")
    public static func monitorTHEOplayer(
        _ player: THEOplayer,
        name: String,
        playerData: MUXSDKCustomerPlayerData,
        videoData: MUXSDKCustomerVideoData,
        softwareVersion: String? = nil,
        automaticErrorTracking: Bool = true
    ) {
        initSDK()

        if bindings.keys.contains(name) {
            destroyPlayer(name: name)
        }

        let binding = Binding(name: name, software: Constants.software, softwareVersion: softwareVersion, automaticErrorTracking: automaticErrorTracking)
        binding.attachPlayer(player)
        bindings[name] = binding

        // This MUXSDKViewInitEvent has to be sent synchronously, or anything in
        // the data event may be blown away by the ViewInit coming in after the DataEvent.
        let event = MUXSDKViewInitEvent()
        MUXSDKCore.dispatchEvent(event, forPlayer: name)
        
        guard let customerData = MUXSDKCustomerData(
            customerPlayerData: playerData,
            videoData: videoData,
            viewData: nil
        ) else {
            return
        }
        
        customerDataStore.setData(customerData, forPlayerName: name)
        dispatchDataEvent(playerName: name, customerData: customerData, videoChange: false)
        binding.dispatchEvent(MUXSDKPlayerReadyEvent.self)
    }


    /**
     Signals that a player is now playing a different video.

     Use this method to signal that the player is now playing a new video. The player name provided must been passed as the name in a monitorTHEOplayer(_:, name:, playerData:, videoData:) call. If the name of the player provided was not previously initialized, no action will be taken.

     - Parameters:
         - name: The name of the player to update
         - customerData: A MUXSDKCustomerData object with player, video, view and custom metadata
     */
    public static func videoChangeForPlayer(name: String, customerData: MUXSDKCustomerData) {
        guard let player = bindings[name] else { return }

        // These events (ViewEnd and ViewInit) need to be sent synchronously, or anything in
        // the data event may be blown away by the ViewInit coming in after the DataEvent.
        let viewEndEvent = MUXSDKViewEndEvent()
        MUXSDKCore.dispatchEvent(viewEndEvent, forPlayer: name)
        player.resetVideoData()
        let viewInitEvent = MUXSDKViewInitEvent()
        MUXSDKCore.dispatchEvent(viewInitEvent, forPlayer: name)

        // Update existing data for player only with non nil properties of the injected customerData
        customerDataStore.updateData(customerData, forPlayerName: name)
        
        guard let updatedCustomerData = customerDataStore.dataForPlayerName(name) else {
            return
        }
        
        dispatchDataEvent(playerName: name, customerData: updatedCustomerData, videoChange: true)
    }
    
    /**
     Signals that a player is now playing a different video.

     Use this method to signal that the player is now playing a new video. The player name provided must been passed as the name in a monitorTHEOplayer(_:, name:, playerData:, videoData:) call. If the name of the player provided was not previously initialized, no action will be taken.

     - Parameters:
         - name: The name of the player to update
         - playerData A MUXSDKCustomerPlayerData object with player metadata
         - videoData A MUXSDKCustomerVideoData object with video metadata
     */
    @available(*, deprecated, message: "Please migrate to videoChangeForPlayer:name:customerData")
    public static func videoChangeForPlayer(name: String, videoData: MUXSDKCustomerVideoData) {
        guard let player = bindings[name] else { return }

        // These events (ViewEnd and ViewInit) need to be sent synchronously, or anything in
        // the data event may be blown away by the ViewInit coming in after the DataEvent.
        let viewEndEvent = MUXSDKViewEndEvent()
        MUXSDKCore.dispatchEvent(viewEndEvent, forPlayer: name)
        player.resetVideoData()
        let viewInitEvent = MUXSDKViewInitEvent()
        MUXSDKCore.dispatchEvent(viewInitEvent, forPlayer: name)

        guard
            let customerData = MUXSDKCustomerData(customerPlayerData: nil, videoData: videoData, viewData: nil)
        else {
            return
        }
        
        customerDataStore.updateData(customerData, forPlayerName: name)
        
        guard let updatedCustomerData = customerDataStore.dataForPlayerName(name) else {
            return
        }
        
        dispatchDataEvent(playerName: name, customerData: updatedCustomerData, videoChange: true)
    }

    /**
     Removes any AVPlayer observers on the associated player.

     When you are done with a player, call destroyPlayer(name:) to remove all observers that were set up when monitorTHEOplayer(_:, name:, playerData:, videoData:) was called and to ensure that any remaining tracking pings are sent to complete the view. If the name of the player provided was not previously initialized, no action will be taken.

     - Parameters:
         - name: The name of the player to destroy
     */
    public static func destroyPlayer(name: String) {
        if let binding = bindings.removeValue(forKey: name) {
            binding.detachPlayer()
        }
    }

    /**
     Sends a custom error to the underlying Mux Data monitor

     - Parameters:
         - name: The name of the player to destroy
         - code: The error code in string format
         - message: The error message in string format
     */
    public static func dispatchError(name: String, code: String, message: String) {
        guard let binding = bindings[name] else { return }
        binding.dispatchError(code: code, message: message)
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
        playerName: String,
        customerData: MUXSDKCustomerData,
        videoChange: Bool
    ) {
        let dataEvent = MUXSDKDataEvent()
        dataEvent.customerPlayerData = customerData.customerPlayerData
        dataEvent.customerVideoData = customerData.customerVideoData
        dataEvent.customerViewData = customerData.customerViewData
        dataEvent.customData = customerData.customData
        dataEvent.videoChange = videoChange
        
        MUXSDKCore.dispatchEvent(dataEvent, forPlayer: playerName)
    }
}

