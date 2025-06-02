//
//  NimbusAPSLegacyRequestManager.swift
//  NimbusRequestAPSKit
//
//  Created on 7/14/22.
//  Copyright © 2022 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit
import DTBiOSSDK

protocol APSLegacyRequestManagerType {
    var usPrivacyString: String? { get set }
    func loadAdsSync(for adSizes: [DTBAdSize]) -> [[AnyHashable: Any]]
}


final class NimbusAPSLegacyRequestManager: APSLegacyRequestManagerType {
    private let requestsDispatchGroup = DispatchGroup()
    private let requestsTimeoutInSeconds: Double
    private let logger: Logger
    private let logLevel: NimbusLogLevel
    
    private var adLoadersDict: [String: DTBAdLoader] = [:]
    var usPrivacyString: String?
    
#if DEBUG
    // When running in test mode auctions may have some delay
    private static let defaultTimeout: Double = 1.5
#else
    private static let defaultTimeout: Double = 0.5
#endif


    init(
        appKey: String,
        logger: Logger,
        logLevel: NimbusLogLevel,
        timeoutInSeconds: Double = defaultTimeout
    ) {
        self.logger = logger
        self.logLevel = logLevel
        self.requestsTimeoutInSeconds = timeoutInSeconds
        
        DTBAds.sharedInstance().setAppKey(appKey)
        DTBAds.sharedInstance().mraidPolicy = CUSTOM_MRAID
        DTBAds.sharedInstance().mraidCustomVersions = ["1.0", "2.0", "3.0"]
        DTBAds.sharedInstance().setLogLevel(logLevel.apsLogLevel)
    }
    
    func loadAdsSync(for adSizes: [DTBAdSize]) -> [[AnyHashable: Any]] {
        var callbacks: [DTBCallback] = []
        adSizes.forEach { adSize in
            let adLoader = reuseOrCreateAdLoader(for: adSize)
            
            requestsDispatchGroup.enter()
            let callback = DTBCallback(loaders: adLoadersDict, requestsDispatchGroup: requestsDispatchGroup)
            callbacks.append(callback)
            adLoader.loadAd(callback)
        }
        
        let result = requestsDispatchGroup.wait(timeout: .now() + requestsTimeoutInSeconds)
        switch result {
        case .success:
            logger.log("APS requests completed successfully", level: logLevel)
        case .timedOut:
            logger.log("APS requests timed out", level: logLevel)
        }
        
        return callbacks.compactMap { $0.payload }
    }
    
    private func reuseOrCreateAdLoader(for adSize: DTBAdSize) -> DTBAdLoader {
        if let existingAdLoader = adLoadersDict.removeValue(forKey: adSize.slotUUID) {
            return existingAdLoader
        }
        
        let adLoader = DTBAdLoader()
        adLoader.setAdSizes([adSize as Any])
        if let usPrivacyString {
            adLoader.putCustomTarget(usPrivacyString, withKey: "us_privacy")
        }
        
        return adLoader
    }
}

// MARK: DTBAdCallback

/// :nodoc:
final class DTBCallback: DTBAdCallback {
    
    private let requestsDispatchGroup: DispatchGroup
    private var adLoadersDict: [String: DTBAdLoader]
    var payload: [AnyHashable: Any]?
    
    init(loaders: [String: DTBAdLoader], requestsDispatchGroup: DispatchGroup) {
        self.adLoadersDict = loaders
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
        
        if let slotId = adResponse.adSize()?.slotUUID, let adLoader = adResponse.dtbAdLoader {
            adLoadersDict[slotId] = adLoader
        }
        
        payload = adResponse.customTargeting()
        requestsDispatchGroup.leave()
    }
}
