//
//  NimbusMobileFuseRequestInterceptor.swift
//  NimbusMobileFuseKit
//  Created on 8/2/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusRequestKit
import MobileFuseSDK

public final class NimbusMobileFuseRequestInterceptor {
    private static let extensionKey = "mfx_buyerdata"
    static var tokenRetrievalTimeout = 0.2
    
    /// Nimbus internal logger
    private let logger: Logger
    
    public init() {
        self.logger = Nimbus.shared.logger
        
        MobileFuseInitializer.shared.initIfNeeded()
    }
}

extension NimbusMobileFuseRequestInterceptor: NimbusRequestInterceptor {
    /// This method should never be called from the main thread
    public func modifyRequest(request: NimbusRequest) {
        let startTime = Date().timeIntervalSince1970
        
        let tokenRequest = MFBiddingTokenRequest()
        tokenRequest.partner = .MOBILEFUSE_PARTNER_NIMBUS
        
        var didTimeOut = false
        
        let group = DispatchGroup()
        group.enter()
        
        MFBiddingTokenProvider.getTokenData(with: tokenRequest) { [weak self, weak request] data in
            defer { group.leave() }
            
            guard !didTimeOut else { return }
            
            let endTime = Date().timeIntervalSince1970
            let timeIntervalMS = 1000 * (endTime - startTime)
            
            self?.logger.log("MobileFuse token data retrieval took \(timeIntervalMS) milliseconds", level: .debug)
            
            if let error = data["error"] {
                self?.logger.log("Couldn't retrieve MobileFuse token data: \(error)", level: .debug)
                return
            }
            
            guard let request else { return }
            
            if request.user == nil {
                request.user = .init()
            }
            if request.user?.extensions == nil {
                request.user?.extensions = [:]
            }
            
            request.user?.extensions?[Self.extensionKey] = NimbusCodable(data)
        }
        
        let result = group.wait(timeout: .now() + Self.tokenRetrievalTimeout)
        if result == .timedOut {
            logger.log("MobileFuse token data retrieval timed out", level: .debug)
            didTimeOut = true
        }
    }
    
    public func didCompleteNimbusRequest(with ad: NimbusAd) {
        logger.log("Completed NimbusRequest for Vungle.", level: .debug)
    }
    
    public func didFailNimbusRequest(with error: NimbusError) {
        logger.log("Failed NimbusRequest for MobileFuse", level: .error)
    }
    
}
