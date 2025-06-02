//
//  NimbusSizeToFormatMapper.swift
//  NimbusGAMKit
//
//  Created on 12/1/22.
//  Copyright © 2022 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit

final class NimbusSizeToFormatMapper {

    func map(width: Int, height: Int) -> NimbusAdFormat {
        switch (width, height) {

        case let (_, h) where h < 90:
            return .banner320x50
        case let (_, h) where h < 250:
            if width >= 728 {
                return .leaderboard
            }
            return .banner320x50

        case let (w, h) where w >= 768 && h >= 768:
            return .init(width: width, height: height)
        case let (w, h) where w >= 480 && h >= 320:
            return .interstitialLandscape
        case let (w, h) where w >= 320 && h >= 480:
            return .interstitialPortrait

        case let (_, h) where h >= 600:
            return .halfScreen
            
        default:
            return .letterbox
        }
    }
}
