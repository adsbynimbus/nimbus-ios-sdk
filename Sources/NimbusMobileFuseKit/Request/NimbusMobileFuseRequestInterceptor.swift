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
    
    /// Nimbus internal logger
    private let logger: Logger
    
    /// Bridge that communicates with MobileFuse SDK
    private let bridge: MobileFuseRequestBridge
    
    public convenience init() {
        self.init(logger: Nimbus.shared.logger, bridge: MobileFuseRequestBridge())
    }
    
    init(logger: Logger, bridge: MobileFuseRequestBridge) {
        self.logger = logger
        self.bridge = bridge
        
        MobileFuseInitializer.shared.initIfNeeded()
    }
}

extension NimbusMobileFuseRequestInterceptor: NimbusRequestInterceptorAsync {
    public func modifyRequest(request: NimbusRequest) async throws -> NimbusRequestDelta {
        let tokenData = try await bridge.tokenData
        try Task.checkCancellation()
        
        return NimbusRequestDelta(userExtension: (Self.extensionKey, NimbusCodable(tokenData)))
    }
}

extension NimbusMobileFuseRequestInterceptor: NimbusRequestInterceptor {
    public func modifyRequest(request: NimbusRequest) {
        // This method is present to maintain backward compatibility, but the async counterpart is used instead.
    }
    
    public func didCompleteNimbusRequest(with ad: NimbusAd) {
        logger.log("Completed NimbusRequest for Mobile Fuse.", level: .debug)
    }
    
    public func didFailNimbusRequest(with error: NimbusError) {
        logger.log("Failed NimbusRequest for MobileFuse", level: .error)
    }
    
}
