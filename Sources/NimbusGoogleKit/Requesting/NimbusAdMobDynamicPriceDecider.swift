//
//  NimbusAdMobDynamicPriceDecider.swift
//  Nimbus
//
//  Created on 7/27/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds

protocol NimbusAdMobDynamicPriceDeciderType: AnyObject {
    func isDynamicPrice(adConfiguration: MediationAdConfiguration) -> Bool
}

final class NimbusAdMobDynamicPriceDecider: NimbusAdMobDynamicPriceDeciderType {
    func isDynamicPrice(adConfiguration: MediationAdConfiguration) -> Bool {
        if !(adConfiguration.extras is NimbusGoogleAdNetworkExtras) {
            return false
        }
        
        // Directly parsing this to an Int does NOT work
        if let parameter = adConfiguration.credentials.settings["parameter"] as? String,
           Int(parameter) != nil {
            return true
        }
        return false
    }
}
