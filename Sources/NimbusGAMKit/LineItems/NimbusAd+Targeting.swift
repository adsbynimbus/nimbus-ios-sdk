//
//  NimbusAd+Targeting.swift
//  NimbusGAMKit
//
//  Created on 8/12/22.
//  Copyright © 2022 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit
import GoogleMobileAds

public extension NimbusAd {
    
    
    /// Add keywords for custom targeting from Nimbus ad to GAMRequest
    /// - Parameters:
    ///   - request: GAMRequest to add keywords to
    ///   - mapping: A mapping composed of multiple LinearPriceGranularities in ascending order. Default: NimbusGAMLinearPriceMapping.banner()
    func applyDynamicPrice(into request: GAMRequest, mapping: NimbusGAMLinearPriceMapping = .banner()) {
        applyDynamicPrice(into: request, keywords: mapping.getKeywords(ad: self))
    }
}

/// :nodoc:
extension NimbusAd {
    func applyDynamicPrice(into request: GAMRequest, keywords: String?) {
        if request.customTargeting == nil {
            request.customTargeting = [:]
        }
        
        request.customTargeting?["na_id"] = auctionId
        request.customTargeting?["na_size"] = "\(adDimensions?.width ?? 0)x\(adDimensions?.height ?? 0)"
        request.customTargeting?["na_network"] = network
        
        let bidKey: String
        
        if auctionType == .video {
            bidKey = "na_bid_video"

            if let duration {
                request.customTargeting?["na_duration"] = String(duration)
            }
        } else {
            bidKey = "na_bid"
        }
        
        request.customTargeting?[bidKey] = Nimbus.shared.testMode ? "0" : keywords
    }
}

/// :nodoc:
extension GAMRequest {
    var hasDynamicPrice: Bool { customTargeting?["na_id"] != nil }
}
