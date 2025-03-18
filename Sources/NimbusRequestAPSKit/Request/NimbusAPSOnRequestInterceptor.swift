//
//  NimbusAPSOnRequestInterceptor.swift
//  NimbusRequestAPSKit
//
//  Created on 3/22/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import DTBiOSSDK

enum NimbusAPSInterceptorError: NimbusError {
    case failedLoadingAPSAd(error: DTBAdError)
    
    var errorDescription: String? {
        switch self {
            case .failedLoadingAPSAd(let error): "Failed loading APS ad with error code: \(error)"
        }
    }
}

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

extension NimbusAPSOnRequestInterceptor: NimbusRequestInterceptorAsync {
    func modifyRequest(request: NimbusRequestKit.NimbusRequest) async throws -> NimbusRequestKit.NimbusRequestDelta {
        currentRequestInFlight = request
        
        guard shouldModifyRequest else {
            Nimbus.shared.logger.log("Skipping initial request modification for APS", level: .debug)
            
            shouldModifyRequest = true
            
            // First request should have APS token data attached by the user
            return .init()
        }
        
        let apsData = try await loadAPSAds()
        return .init(impressionExtensions: ["aps" : NimbusCodable(apsData)])
    }
    
    func loadAPSAd(loader: DTBAdLoader) async throws -> DTBAdResponse {
        try await withUnsafeThrowingContinuation { continuation in
            let callbackWrapper = APSAdCallbackWrapper(continuation: continuation)
            loader.loadAd(callbackWrapper)
        }
    }
    
    func loadAPSAds() async throws -> [[String: String]] {
        try await withThrowingTaskGroup(of: DTBAdResponse?.self) { [weak self] group in
            guard let adLoaders = self?.adLoaders else { return [] }
            
            for adLoader in adLoaders {
                group.addTask {
                    do {
                        return try await self?.loadAPSAd(loader: adLoader)
                    } catch {
                        Nimbus.shared.logger.log("Failed loading aps ad: \(adLoader.correlationId)", level: .debug)
                        return nil
                    }
                }
            }
            
            var apsData: [[String: String]] = []
            
            for try await response in group {
                guard let response, let customTargeting = response.customTargeting() else { continue }
                
                apsData.append(customTargeting)
            }
            
            return apsData
        }
    }
}

final class APSAdCallbackWrapper: NSObject, DTBAdCallback {
    private let continuation: UnsafeContinuation<DTBAdResponse, Error>?

    init(continuation: UnsafeContinuation<DTBAdResponse, Error>) {
        self.continuation = continuation
        super.init()
    }

    func onSuccess(_ adResponse: DTBAdResponse?) {
        guard let adResponse = adResponse, let continuation = continuation else { return }
        continuation.resume(returning: adResponse)
    }

    func onFailure(_ error: DTBAdError) {
        guard let continuation = continuation else { return }
        continuation.resume(throwing: NimbusAPSInterceptorError.failedLoadingAPSAd(error: error))
    }
}

// MARK: NimbusRequestInterceptor

extension NimbusAPSOnRequestInterceptor: NimbusRequestInterceptor {
    func modifyRequest(request: NimbusRequestKit.NimbusRequest) {}
    
    func didCompleteNimbusRequest(with ad: NimbusCoreKit.NimbusAd) {
        Nimbus.shared.logger.log("Completed NimbusRequest for APS", level: .debug)
        
        clearAPSParamsAndRequest()
    }
    
    func didFailNimbusRequest(with error: NimbusCoreKit.NimbusError) {
        Nimbus.shared.logger.log("Failed NimbusRequest for APS", level: .error)
        
        clearAPSParamsAndRequest()
    }
}
