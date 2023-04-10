//
//  NimbusAd+Targeting.swift
//  NimbusGAMKit
//
//  Created by Inder Dhir on 8/12/22.
//  Copyright © 2022 Timehop. All rights reserved.
//

@_exported import NimbusRequestKit
import GoogleMobileAds

public extension NimbusAd {
    
    
    /// Add keywords for custom targeting from Nimbus ad to GAMRequest
    /// - Parameters:
    ///   - request: GAMRequest to add keywords to
    ///   - mapping: A mapping composed of multiple LinearPriceGranularities in ascending order. Default: NimbusGAMLinearPriceMapping.banner()
    func applyDynamicPrice(into request: GAMRequest, mapping: NimbusGAMLinearPriceMapping = .banner()) {
        if request.customTargeting == nil {
            request.customTargeting = [:]
        }
        
        request.customTargeting?["na_id"] = auctionId
        if auctionType == .video {
            request.customTargeting?["na_bid_video"] = mapping.getKeywords(ad: self)

            if let duration {
                request.customTargeting?["na_duration"] = String(duration)
            }
        } else {
            request.customTargeting?["na_bid"] = mapping.getKeywords(ad: self)
        }
    }
}
