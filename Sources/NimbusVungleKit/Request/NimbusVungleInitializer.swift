//
//  NimbusVungleInitializer.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 19/05/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

import VungleAdsSDK

/// Protocol used for starting VungleAds
protocol NimbusVungleInitializerType {
    var isInitialized: Bool { get }
    var biddingToken: String { get }
    
    func initWithAppId(_ appID: String, completion: @escaping (NSError?) -> Void)
}

/// Nimbus default wrapper for starting VungleAds
final class NimbusVungleInitializer: NimbusVungleInitializerType {
        
    var isInitialized: Bool { VungleAds.isInitialized() }
    var biddingToken: String { VungleAds.getBiddingToken() }
    
    init() {}
    
    func initWithAppId(_ appID: String, completion: @escaping (NSError?) -> Void) {
        VungleAds.initWithAppId(appID) { error in
            completion(error)
        }
    }
}
