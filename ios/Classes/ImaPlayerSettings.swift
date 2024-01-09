//
//  ImaPlayerSettings.swift
//  ima_player
//
//  Created by gece on 26.12.2023.
//

import Foundation


struct ImaPlayerSettings {
    var uri: URL!
    var tag: String?
    var isMixed: Bool = false
    var autoPlay: Bool = true
    var initialVolume: Double = 1.0
    var showPlaybackControls:Bool = true

    var isAdsEnabled: Bool {
        get {
            return tag != nil && !tag!.isEmpty
        }
    }
}
