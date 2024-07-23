//
//  NimbusGAMLinearPriceGranularity.swift
//  NimbusGAMKit
//
//  Created on 10/21/20.
//  Copyright © 2020 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit

/**
 * A mapping using a linear step function to generate the keywords
 * By default, this class will map to a keyword of "nimbus{width}_{height}:{bucket}" i.e nimbus320_50:500 for a bid at 5 dollars.
 */
public struct NimbusGAMLinearPriceGranularity: NimbusDynamicPriceMapping, Comparable, Equatable {
    
    /// The minimum bid in cents
    public let min: Int
    
    /// The maximum bid in cents
    public let max: Int
    
    /// The step size for each line item mapping. Default: 20
    public let step: Int
    
    /**
     Constructs a new `NimbusGAMLinearPriceGranularity`
     
     - Parameters:
     - min: The minimum bid in cents
     - max: The maximum bid in cents
     - step: The step size for each line item mapping. Default: 20
     */
    public init(min: Int, max: Int, step: Int = 20) {
        self.min = min
        self.max = max
        self.step = step
    }
    
    /**
     Constructs a new `NimbusGAMLinearPriceGranularity`
     
     - Parameters:
     - min: The minimum bid in cents
     - max: The maximum bid in cents
     */
    public init(min: Int, max: Int) {
        self.init(min: min, max: max, step: 20)
    }
    
    /**
     Returns the keywords to be inserted in the GAM ad
     
     - Parameters:
     - ad: An ad from Nimbus
     
     - Returns: The keywords to set on the GAM view
     */
    public func getKeywords(ad: NimbusAd) -> String? {
        String((ad.bidInCents - (ad.bidInCents % step)).nimbusClamped(to: min...max))
    }
    
    /// :nodoc:
    public static func < (lhs: NimbusGAMLinearPriceGranularity, rhs: NimbusGAMLinearPriceGranularity) -> Bool {
        lhs.min < rhs.min
    }
    
    /// :nodoc:
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.min == rhs.min
    }
}
