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
        for adConfiguration: GADMediationBannerAdConfiguration
    ) -> NimbusRequest
    
    func createInterstitialRequest(
        for adConfiguration: GADMediationInterstitialAdConfiguration
    ) -> NimbusRequest
    
    func createRewardedRequest(for adConfiguration: GADMediationRewardedAdConfiguration) -> NimbusRequest
}

final class NimbusGoogleRequestCreator: NimbusGoogleRequestCreatorType {
    private let positionCreator: NimbusGooglePositionCreatorType
    private let sizeToFormatMapper: NimbusGoogleSizeToFormatMapperType
    
    init(
        positionCreator: NimbusGooglePositionCreatorType = NimbusGooglePositionCreator(),
        sizeToFormatMapper: NimbusGoogleSizeToFormatMapperType = NimbusGoogleSizeToFormatMapper()
    ) {
        self.positionCreator = positionCreator
        self.sizeToFormatMapper = sizeToFormatMapper
    }
    
    func createBannerRequest(for adConfiguration: GADMediationBannerAdConfiguration) -> NimbusRequest {
        let size = adConfiguration.adSize.size
        let adSizeToNimbusFormat = sizeToFormatMapper.map(width: Int(size.width), height: Int(size.height))
        
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
    
    func createInterstitialRequest(for adConfiguration: GADMediationInterstitialAdConfiguration) -> NimbusRequest {
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
    
    func createRewardedRequest(for adConfiguration: GADMediationRewardedAdConfiguration) -> NimbusRequest {
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
