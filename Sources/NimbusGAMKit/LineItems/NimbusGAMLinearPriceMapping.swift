//
//  NimbusGAMLinearPriceMapping.swift
//  NimbusGAMKit
//
//  Created on 12/10/20.
//  Copyright © 2020 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit
import Foundation

/// A mapping composed of multiple LinearPriceGranularities in ascending order
public struct NimbusGAMLinearPriceMapping: NimbusDynamicPriceMapping {
    
    /// The granularities used in this mapping
    let granularities: [NimbusGAMLinearPriceGranularity]
    
    /**
     Constructs a new `LinearPriceMapping`
     
     - Parameters:
     -  granularities: the granularities to use
     */
    public init(granularities: [NimbusGAMLinearPriceGranularity]) {
        self.granularities = granularities.sorted()
    }
    
    /**
     Linearly searches the granularity mappings and returns the keywords to be inserted
     
     - Parameters:
     - ad: An ad from Nimbus
     
     - Returns: The keywords to set
     */
    public func getKeywords(ad: NimbusAd) -> String? {
        for granularity in granularities {
            if ad.bidInCents < granularity.max {
                return granularity.getKeywords(ad: ad)
            }
        }
        return granularities.last?.getKeywords(ad: ad)
    }
    
    /**
     * Default Mapping for Banner ad units
     *
     * $0.01 increments: $0.01 - $3.00   (ex. na_bid = {1, 2, 3, 4 ... 300})
     * $0.05 increments: $3.00 - $8.00   (ex. na_bid = {300, 305, 310, 315 ... 800})
     * $0.50 increments: $8.00 - $20.00  (ex. na_bid = {800, 850, 900, 950 ... 2000})
     * $1.00 increments: $20.00 - $35.00 (ex. na_bid = {2000, 2100, 2200, 2300 ... 3500})
     */
    public static func banner() -> NimbusGAMLinearPriceMapping {
        NimbusGAMLinearPriceMapping(
            granularities: [
                NimbusGAMLinearPriceGranularity(min: 0, max: 300, step: 1),
                NimbusGAMLinearPriceGranularity(min: 300, max: 800, step: 5),
                NimbusGAMLinearPriceGranularity(min: 800, max: 2000, step: 50),
                NimbusGAMLinearPriceGranularity(min: 2000, max: 3500, step: 100)
            ]
        )
    }
    
    /**
     * Default Mapping for Fullscreen (Interstitial) ad units
     *
     * $0.05 increments: $0.05 - $35.00  (ex. na_bid = {5, 10, 15, 20 ... 3500})
     * $1.00 increments: $35.00 - $60.00 (ex. na_bid = {3500, 3600, 3700, 3800 ... 6000})
     */
    public static func fullscreen() -> NimbusGAMLinearPriceMapping {
        NimbusGAMLinearPriceMapping(
            granularities: [
                NimbusGAMLinearPriceGranularity(min: 0, max: 3500, step: 5),
                NimbusGAMLinearPriceGranularity(min: 3500, max: 6000, step: 100)
            ]
        )
    }
}
