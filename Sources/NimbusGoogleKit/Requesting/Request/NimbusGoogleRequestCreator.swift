//
//  NimbusGoogleRequestCreator.swift
//  Nimbus
//
//  Created on 7/27/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import GoogleMobileAds
import NimbusRequestKit

protocol NimbusGoogleRequestCreatorType {
    func createBannerRequest(
        for adConfiguration: MediationBannerAdConfiguration
    ) -> NimbusRequest
    
    func createInterstitialRequest(
        for adConfiguration: MediationInterstitialAdConfiguration
    ) -> NimbusRequest
    
    func createRewardedRequest(for adConfiguration: MediationRewardedAdConfiguration) -> NimbusRequest
}

final class NimbusGoogleRequestCreator: NimbusGoogleRequestCreatorType {
    private let positionCreator: NimbusGooglePositionCreatorType
    
    init(positionCreator: NimbusGooglePositionCreatorType = NimbusGooglePositionCreator()) {
        self.positionCreator = positionCreator
    }
    
    func createBannerRequest(for adConfiguration: MediationBannerAdConfiguration) -> NimbusRequest {
        let size = adConfiguration.adSize.size
        let adSizeToNimbusFormat = NimbusAdFormat.mapFrom(width: Int(size.width), height: Int(size.height))
        
        let position = positionCreator.create(for: adConfiguration)
        let nimbusRequest = NimbusRequest.forBannerAd(position: position, format: adSizeToNimbusFormat)
        nimbusRequest.configureViewability(
            partnerName: Nimbus.shared.sdkName,
            partnerVersion: Nimbus.shared.version
        )
        if adConfiguration.isTestRequest {
            nimbusRequest.isTest = true
        }
        return nimbusRequest
    }
    
    func createInterstitialRequest(for adConfiguration: MediationInterstitialAdConfiguration) -> NimbusRequest {
        let position = positionCreator.create(for: adConfiguration)
        let nimbusRequest = NimbusRequest.forInterstitialAd(position: position)
        nimbusRequest.configureViewability(
            partnerName: Nimbus.shared.sdkName,
            partnerVersion: Nimbus.shared.version
        )
        if adConfiguration.isTestRequest {
            nimbusRequest.isTest = true
        }
        return nimbusRequest
    }
    
    func createRewardedRequest(for adConfiguration: MediationRewardedAdConfiguration) -> NimbusRequest {
        let position = positionCreator.create(for: adConfiguration)
        let nimbusRequest = NimbusRequest.forRewardedVideo(position: position)
        nimbusRequest.configureViewability(
            partnerName: Nimbus.shared.sdkName,
            partnerVersion: Nimbus.shared.version
        )
        if adConfiguration.isTestRequest {
            nimbusRequest.isTest = true
        }
        return nimbusRequest
    }
}
