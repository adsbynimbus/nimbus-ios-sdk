//
//  NimbusAdMobRequestInterceptor.swift
//  NimbusAdMobKit
//  Created on 9/3/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusRenderKit
import NimbusRequestKit
import GoogleMobileAds

final class NimbusAdMobRequestInterceptor {
    private static let extensionKey = "admob_gde_signals"
    private static let adMobTimeout = 0.5
    
    private let logger: Logger
    
    let adUnitId: String
    let adType: NimbusAdType
    let nativeAdOptions: NimbusAdMobNativeAdOptions?
    private let bridge: AdMobRequestBridge
    
    init(
        adUnitId: String,
        adType: NimbusAdType,
        nativeAdOptions: NimbusAdMobNativeAdOptions? = nil,
        logger: Logger = Nimbus.shared.logger,
        bridge: AdMobRequestBridge = AdMobRequestBridge()
    ) {
        self.adUnitId = adUnitId
        self.adType = adType
        self.nativeAdOptions = nativeAdOptions
        self.logger = logger
        self.bridge = bridge
    }
}

extension NimbusAdMobRequestInterceptor: NimbusRequestInterceptorAsync {
    func modifyRequest(request: NimbusRequest) async throws -> NimbusRequestDelta {
        bridge.set(coppa: request.regs?.coppa)
        
        let signalRequest = try adType.adMobSignalRequest(from: request, adUnitId: adUnitId, nativeAdOptions: nativeAdOptions)
        let signal = try await bridge.generateSignal(request: signalRequest)
        
        try Task.checkCancellation()
        return NimbusRequestDelta(userExtension: ("admob_gde_signals", NimbusCodable(signal)))
    }
}

extension NimbusAdMobRequestInterceptor: NimbusRequestInterceptor {
    
    func modifyRequest(request: NimbusRequest) {
        // This method is present to maintain backward compatibility, but the async counterpart is used instead.
    }
    
    func didCompleteNimbusRequest(with ad: NimbusAd) {
        logger.log("Completed NimbusRequest for AdMob", level: .debug)
    }
    
    func didFailNimbusRequest(with error: any NimbusError) {
        logger.log("Failed NimbusRequest for AdMob", level: .error)
    }
}
