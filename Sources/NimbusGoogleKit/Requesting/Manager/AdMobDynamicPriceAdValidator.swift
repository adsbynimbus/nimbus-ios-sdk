//
//  AdMobDynamicPriceAdValidator.swift
//  Nimbus
//
//  Created on 7/29/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds
@_exported import NimbusKit

protocol AdMobDynamicPriceAdValidatorType: AnyObject {
    func validate(ad: NimbusAd, for adConfiguration: GADMediationAdConfiguration) throws
}

final class AdMobDynamicPriceAdValidator: AdMobDynamicPriceAdValidatorType {
    
    private let logger: Logger
    
    private enum DynamicPriceError: LocalizedError {
        case bidPriceLessThanParameter
        
        var errorDescription: String? {
            "Ad's bid price is less than parameter"
        }
    }
    
    init(logger: Logger = Nimbus.shared.logger) {
        self.logger = logger
    }
    
    func validate(ad: NimbusAd, for adConfiguration: GADMediationAdConfiguration) throws {
        // Directly parsing this to an Int does NOT work
        if let parameter = adConfiguration.credentials.settings["parameter"] as? String,
           let parameterAsInt = Int(parameter),
           ad.bidInCents >= parameterAsInt {
            logger.log("Bid price validation for AdMob Dynamic Price succeeded", level: .debug)
            
            return
        }
        
        logger.log("Bid price validation for AdMob Dynamic Price failed", level: .error)
        
        throw DynamicPriceError.bidPriceLessThanParameter
    }
}
