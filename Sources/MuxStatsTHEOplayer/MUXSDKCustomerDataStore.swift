//
//  MUXSDKCustomerDataStore.swift
//  MUXSDKStatsTHEOplayer
//
//  Created by Stephanie Zuñiga on 4/5/22.
//  Copyright © 2022 Mux, Inc. All rights reserved.
//

import Foundation
import MuxCore

class MUXSDKCustomerDataStore {
    private var store: [String: MUXSDKCustomerData] = [:]
    
    // Overwrites any pre-existing data for the player
    func setData(_ data: MUXSDKCustomerData, forPlayerName name: String) {
        self.store[name] = data
    }
    
    // Update existing data for player only with non nil properties of the injected data
    // For all properties that are nil in the injected data, pre-existing values will be preserved
    func updateData(_ data: MUXSDKCustomerData, forPlayerName name: String) {
        // Get current data for player name
        let currentData = self.store[name]
        
        // Update data
        if let playerData = data.customerPlayerData {
            currentData?.customerPlayerData = playerData
        }
        
        if let videoData = data.customerVideoData {
            currentData?.customerVideoData = videoData
        }
        
        if let viewData = data.customerViewData {
            currentData?.customerViewData = viewData
        }
        
        if let customData = data.customData {
            currentData?.customData = customData
        }
        
        // Store updated data
        self.store[name] = currentData
    }
    
    func dataForPlayerName(_ name: String) -> MUXSDKCustomerData? {
        return self.store[name]
    }
}

