//
//  NimbusGooglePositionCreator.swift
//  NimbusGoogleKit
//
//  Created on 6/29/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds

protocol NimbusGooglePositionCreatorType {
    func create(for adConfiguration: MediationBannerAdConfiguration) -> String
    func create(for adConfiguration: MediationInterstitialAdConfiguration) -> String
    func create(for adConfiguration: MediationRewardedAdConfiguration) -> String
}

final class NimbusGooglePositionCreator: NimbusGooglePositionCreatorType {
    
    func create(for adConfiguration: MediationBannerAdConfiguration) -> String {
        if let extras = adConfiguration.extras as? NimbusGoogleAdNetworkExtras {
            return extras.position
        }
        return "Nimbus Google Banner"
    }
    
    func create(for adConfiguration: MediationInterstitialAdConfiguration) -> String {
        if let extras = adConfiguration.extras as? NimbusGoogleAdNetworkExtras {
            return extras.position
        }
        return "Nimbus Google Interstitial"
    }
    
    func create(for adConfiguration: MediationRewardedAdConfiguration) -> String {
        if let extras = adConfiguration.extras as? NimbusGoogleAdNetworkExtras {
            return extras.position
        }
        return "Nimbus Google Rewarded"
    }
}
