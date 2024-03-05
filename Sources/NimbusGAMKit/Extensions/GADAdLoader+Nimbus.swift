//
//  GADAdLoader+Nimbus.swift
//  Nimbus
//  Created on 2/27/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds
import NimbusCoreKit

public extension GADAdLoader {
    private static var nimbusAdKey: Void?
    
    private(set) var nimbusAd: NimbusAd? {
        get {
            objc_getAssociatedObject(
                self,
                &Self.nimbusAdKey
            ) as? NimbusAd
        }
        set {
            objc_setAssociatedObject(
                self,
                &Self.nimbusAdKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    /// This method applies dynamic price targeting and calls `GADAdLoader.load()`.
    /// - Parameters:
    ///     - gamRequest: Instance of GAMRequest
    ///     - ad: NimbusAd to render if Nimbus wins
    ///     - mapping: Default is `NimbusGAMLinearPriceMapping.banner()`
    func loadDynamicPrice(
        gamRequest: GAMRequest,
        ad: NimbusAd? = nil,
        mapping: NimbusGAMLinearPriceMapping = .banner()
    ) {
        if !gamRequest.hasDynamicPrice {
            ad?.applyDynamicPrice(into: gamRequest, mapping: mapping)
        }
        
        nimbusAd = ad
        load(gamRequest)
    }
}
