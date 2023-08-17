//
//  NimbusGooglePositionCreator.swift
//  NimbusGoogleKit
//
//  Created by Inder Dhir on 6/29/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

import GoogleMobileAds

protocol NimbusGooglePositionCreatorType {
    func create(for adConfiguration: GADMediationBannerAdConfiguration) -> String
    func create(for adConfiguration: GADMediationInterstitialAdConfiguration) -> String
    func create(for adConfiguration: GADMediationRewardedAdConfiguration) -> String
}

final class NimbusGooglePositionCreator: NimbusGooglePositionCreatorType {
    
    func create(for adConfiguration: GADMediationBannerAdConfiguration) -> String {
        if let extras = adConfiguration.extras as? NimbusGoogleAdNetworkExtras {
            return extras.position
        }
        return "Nimbus Google Banner"
    }
    
    func create(for adConfiguration: GADMediationInterstitialAdConfiguration) -> String {
        if let extras = adConfiguration.extras as? NimbusGoogleAdNetworkExtras {
            return extras.position
        }
        return "Nimbus Google Interstitial"
    }
    
    func create(for adConfiguration: GADMediationRewardedAdConfiguration) -> String {
        if let extras = adConfiguration.extras as? NimbusGoogleAdNetworkExtras {
            return extras.position
        }
        return "Nimbus Google Rewarded"
    }
}
