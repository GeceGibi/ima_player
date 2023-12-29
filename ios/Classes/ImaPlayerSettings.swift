//
//  ImaPlayerSettings.swift
//  ima_player
//
//  Created by gece on 26.12.2023.
//

import Foundation


struct ImaPlayerSettings {

    var isMuted: Bool = false
    var isMixed: Bool = false
    var autoPlay: Bool = true
    var isAdsEnabled: Bool = true
    var showPlaybackControls: Bool = true
    
    var imaTag: String?
    var videoUrl: String?
}
