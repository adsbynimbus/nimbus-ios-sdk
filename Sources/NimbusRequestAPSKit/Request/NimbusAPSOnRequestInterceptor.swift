//
//  NimbusAPSOnRequestInterceptor.swift
//  NimbusRequestAPSKit
//
//  Created on 3/22/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import DTBiOSSDK

final class NimbusAPSOnRequestInterceptor {
    weak var currentRequestInFlight: NimbusRequest?
    var shouldModifyRequest = false
    var adLoaders: [DTBAdLoader]
    var requestManager: APSRequestManagerType
    private let viewabilityManager = NimbusAPSViewabilityManager()

    init(adLoaders: [DTBAdLoader], requestManager: APSRequestManagerType? = nil) {
        self.adLoaders = adLoaders
        
        self.requestManager = requestManager ?? NimbusAPSRequestManager()
        
        Nimbus.shared.logger.log("APS provider initialized", level: .info)
    }
    
    @inlinable
    func appendLoader(_ loader: DTBAdLoader) {
        adLoaders.append(loader)
        shouldModifyRequest = false
    }
    
    private func clearAPSParamsAndRequest() {
        guard let currentRequestInFlight else { return }
        
        if currentRequestInFlight.impressions.count > 0 {
            currentRequestInFlight.impressions[0].extensions?["aps"] = nil
        }
        self.currentRequestInFlight = nil
    }
}

// MARK: NimbusRequestInterceptor

extension NimbusAPSOnRequestInterceptor: NimbusRequestInterceptor {
    func modifyRequest(request: NimbusRequestKit.NimbusRequest) {
        guard shouldModifyRequest else {
            Nimbus.shared.logger.log("Skipping initial request modification for APS", level: .debug)

            currentRequestInFlight = request
            shouldModifyRequest = true
            return
        }
        
        Nimbus.shared.logger.log("Modifying NimbusRequest for APS", level: .debug)
        
        currentRequestInFlight = request
        
        let (adLoaders, apsResponses) = requestManager.loadAdsSync(with: adLoaders)
        guard apsResponses.count > 0 else {
            Nimbus.shared.logger.log("No APS ad payload to inject into the NimbusRequest", level: .debug)

            return
        }
        
        Nimbus.shared.logger.log("Refreshing ad loaders from APS responses", level: .debug)
        self.adLoaders = adLoaders

        Nimbus.shared.logger.log("Modifying NimbusRequest with APS payload", level: .debug)
        apsResponses.forEach { request.addAPSResponse($0) }
    }
    
    func didCompleteNimbusRequest(with ad: NimbusCoreKit.NimbusAd) {
        Nimbus.shared.logger.log("Completed NimbusRequest for APS", level: .debug)
        
        clearAPSParamsAndRequest()
    }
    
    func didFailNimbusRequest(with error: NimbusCoreKit.NimbusError) {
        Nimbus.shared.logger.log("Failed NimbusRequest for APS", level: .error)
        
        clearAPSParamsAndRequest()
    }
}
