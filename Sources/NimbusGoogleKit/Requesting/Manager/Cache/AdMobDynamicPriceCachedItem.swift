//
//  AdMobDynamicPriceCachedItem.swift
//  Nimbus
//
//  Created by Inder Dhir on 7/31/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

import Foundation
@_exported import NimbusKit

final class AdMobDynamicPriceCachedItem {
    enum ItemType {
        case failed(error: Error)
        case fill(ad: NimbusAd, companionAd: NimbusCompanionAd?)
    }
    let itemType: ItemType
    let timestamp: Int
    var price: String?
    
    init(ad: NimbusAd, companionAd: NimbusCompanionAd? = nil) {
        itemType = .fill(ad: ad, companionAd: companionAd)
        timestamp = Int(Date().timeIntervalSince1970)
    }
    
    init(error: Error) {
        itemType = .failed(error: error)
        timestamp = Int(Date().timeIntervalSince1970)
    }
}
