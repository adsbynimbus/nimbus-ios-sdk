//
//  NimbusAPSRequestManager.swift
//  NimbusRequestAPSKit
//
//  Created on 3/22/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
@_exported import NimbusRequestKit
import DTBiOSSDK

public protocol APSRequestManagerType {
    func loadAdsSync(with loaders: [DTBAdLoader]) ->  ([DTBAdLoader], [DTBAdResponse])
}

final class NimbusAPSRequestManager: APSRequestManagerType {
    private let requestsDispatchGroup = DispatchGroup()

#if DEBUG
    // When running in test mode auctions may have some delay
    private let requestsTimeoutInSeconds: Double = 1.5
#else
    private let requestsTimeoutInSeconds: Double = 0.5
#endif

    private let logger: Logger
    private let logLevel: NimbusLogLevel
    
    init(
        logger: Logger = Nimbus.shared.logger,
        logLevel: NimbusLogLevel = Nimbus.shared.logLevel
    ) {
        self.logger = logger
        self.logLevel = logLevel
    }
    
    func loadAdsSync(with loaders: [DTBAdLoader]) -> ([DTBAdLoader], [DTBAdResponse]) {
        var callbacks: [DTBLoadingCallback] = []

        loaders.forEach { loader in
            requestsDispatchGroup.enter()
            
            let callback = DTBLoadingCallback(
                loader: loader,
                requestsDispatchGroup: requestsDispatchGroup
            )
            callbacks.append(callback)
            loader.loadAd(callback)
        }
        
        let result = requestsDispatchGroup.wait(timeout: .now() + requestsTimeoutInSeconds)
        switch result {
        case .success:
            logger.log("APS requests completed successfully", level: .debug)
        case .timedOut:
            logger.log("APS requests timed out", level: .debug)
        }
        
        let adLoaders = callbacks.compactMap { $0.loader }
        let successfulResponses = callbacks.compactMap { $0.response }
        return (adLoaders, successfulResponses)
    }
}

// MARK: DTBAdCallback

/// :nodoc:
final class DTBLoadingCallback: DTBAdCallback {
    
    private let requestsDispatchGroup: DispatchGroup
    var loader: DTBAdLoader
    var response: DTBAdResponse?
    
    init(loader: DTBAdLoader, requestsDispatchGroup: DispatchGroup) {
        self.loader = loader
        self.requestsDispatchGroup = requestsDispatchGroup
    }

    /// :nodoc:
    public func onFailure(_ error: DTBAdError) {
        Nimbus.shared.logger.log("APS ad fetching failed with code: \(error.rawValue)", level: .error)
        
        requestsDispatchGroup.leave()
    }

    /// :nodoc:
    public func onSuccess(_ adResponse: DTBAdResponse!) {
        Nimbus.shared.logger.log("APS ad fetching succeeded", level: .debug)
                
        if let adloader = adResponse.dtbAdLoader {
            loader = adloader
        }
        response = adResponse
        
        requestsDispatchGroup.leave()
    }
}
