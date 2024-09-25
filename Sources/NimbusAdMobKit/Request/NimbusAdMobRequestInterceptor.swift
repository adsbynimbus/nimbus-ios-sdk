//
//  NimbusAdMobRequestInterceptor.swift
//  NimbusAdMobKit
//  Created on 9/3/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusRequestKit
import GoogleMobileAds

final class NimbusAdMobRequestInterceptor {
    private static let extensionKey = "admob_gde_signals"
    private static let adMobTimeout = 0.5
    
    private let logger: Logger
    
    let adUnitId: String
    let adType: NimbusAdMobAdType
    let nativeAdOptions: NimbusAdMobNativeAdOptions?
    
    /// AdMob signal provider (dependency injection for unit tests)
    private let provider: (GADSignalRequest, @escaping (GADSignal?, Error?) -> Void) -> Void
    
    init(
        adUnitId: String,
        adType: NimbusAdMobAdType,
        nativeAdOptions: NimbusAdMobNativeAdOptions? = nil,
        logger: Logger = Nimbus.shared.logger,
        provider: ((GADSignalRequest, @escaping (GADSignal?, Error?) -> Void) -> Void)? = nil
    ) {
        self.adUnitId = adUnitId
        self.adType = adType
        self.nativeAdOptions = nativeAdOptions
        self.logger = logger
        
        if let provider {
            self.provider = provider
        } else {
            self.provider = { (signalRequest, callback) in
                GADMobileAds.generateSignal(signalRequest, completionHandler: callback)
            }
        }
    }
}

extension NimbusAdMobRequestInterceptor: NimbusRequestInterceptor {
    /// This method should never be called from the main thread
    func modifyRequest(request: NimbusRequest) {
        // 3-state COPPA setting as documented: https://developers.google.com/ad-manager/mobile-ads-sdk/ios/targeting#child-directed_setting
        let coppa = request.regs?.coppa
        GADMobileAds
            .sharedInstance()
            .requestConfiguration.tagForChildDirectedTreatment = coppa == nil ? nil : NSNumber(booleanLiteral: coppa!)
        
        guard let signalRequest = createSignalRequest(request: request) else {
            logger.log("Failed creating AdMob request from NimbusRequest", level: .debug)
            return
        }
        
        let startTime = Date().timeIntervalSince1970
        
        var didTimeOut = false
        
        let group = DispatchGroup()
        group.enter()
        
        provider(signalRequest) { [weak self, weak request] signal, error in
            defer { group.leave() }
            
            guard !didTimeOut, let request else { return }
            
            let endTime = Date().timeIntervalSince1970
            let timeIntervalMS = 1000 * (endTime - startTime)
            self?.logger.log("AdMob signal retrieval took \(timeIntervalMS) milliseconds", level: .debug)
            
            if let error {
                self?.logger.log("Couldn't generate AdMob request, error: \(error.localizedDescription)", level: .debug)
            } else if let signal {
                if request.user == nil { request.user = .init() }
                if request.user?.extensions == nil { request.user?.extensions = [:] }
                request.user?.extensions?["admob_gde_signals"] = NimbusCodable(signal.signalString)
            }
        }
        
        let result = group.wait(timeout: .now() + Self.adMobTimeout)
        if result == .timedOut {
            logger.log("AdMob bid request timed out", level: .debug)
            didTimeOut = true
        }
    }
    
    func didCompleteNimbusRequest(with ad: NimbusAd) {
        logger.log("Completed NimbusRequest for AdMob", level: .debug)
    }
    
    func didFailNimbusRequest(with error: any NimbusError) {
        logger.log("Failed NimbusRequest for AdMob", level: .error)
    }
    
    func createSignalRequest(request: NimbusRequest) -> GADSignalRequest? {
        guard let signalRequest = signalFromAdType(request: request) else { return nil }
        
        signalRequest.adUnitID = adUnitId
        signalRequest.requestAgent = "nimbus"
        
        let extras = GADExtras()
        extras.additionalParameters = ["query_info_type": "requester_type_2"]
        signalRequest.register(extras)
        return signalRequest
    }
    
    private func signalFromAdType(request: NimbusRequest) -> GADSignalRequest? {
        guard let impression = request.impressions.first else {
            logger.log("NimbusRequest was not properly constructed - missing NimbusImpression", level: .debug)
            return nil
        }
        
        switch adType {
        case .banner:
            if let banner = impression.banner, impression.video == nil {
               let signalRequest = GADBannerSignalRequest(signalType: "requester_type_2")
               signalRequest.adSize = GADAdSizeFromCGSize(CGSize(width: banner.width, height: banner.height))
               return signalRequest
           }
        case .native:
            let signal = GADNativeSignalRequest(signalType: "requester_type_2")
            if let nativeAdOptions {
                signal.disableImageLoading = nativeAdOptions.disableImageLoading
                signal.shouldRequestMultipleImages = nativeAdOptions.shouldRequestMultipleImages
                signal.mediaAspectRatio = nativeAdOptions.mediaAspectRatio
                signal.preferredAdChoicesPosition = nativeAdOptions.preferredAdChoicesPosition
                signal.customMuteThisAdRequested = nativeAdOptions.customMuteThisAdRequested
            }
            return signal
        case .interstitial:
            return GADInterstitialSignalRequest(signalType: "requester_type_2")
        case .rewarded:
            return GADRewardedSignalRequest(signalType: "requester_type_2")
        }
        
        logger.log("Unsupported AdMob ad type. Supported are: Blocking (interstitial, rewarded), Inline (banner, native)", level: .debug)
        return nil
    }
}
