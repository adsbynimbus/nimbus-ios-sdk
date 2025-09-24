//
//  NimbusInMobiRequestInterceptor.swift
//  Nimbus
//  Created on 7/31/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusRequestKit
import NimbusRenderKit

final class NimbusInMobiRequestInterceptor {
    
    private static let extensionKey = "inmobi_buyeruid"
    
    /// Nimbus internal logger
    private let logger: Logger
    
    /// Bridge that communicates with InMobi SDK
    private let bridge: InMobiRequestBridge
    
    let placementId: Int64
    
    public convenience init(placementId: Int64) {
        self.init(placementId: placementId, logger: Nimbus.shared.logger, bridge: InMobiRequestBridge())
    }
    
    init(placementId: Int64, logger: Logger, bridge: InMobiRequestBridge) {
        self.placementId = placementId
        self.logger = logger
        self.bridge = bridge
    }
}

extension NimbusInMobiRequestInterceptor: NimbusRequestInterceptorAsync {
    public func modifyRequest(request: NimbusRequest) async throws -> NimbusRequestDelta {
        await bridge.set(coppa: request.regs?.coppa)
        
        let bidToken = try await bridge.bidToken
        try Task.checkCancellation()
        
        return NimbusRequestDelta(userExtension: (Self.extensionKey, NimbusCodable(bidToken)))
    }
}

extension NimbusInMobiRequestInterceptor: NimbusRequestInterceptor {
    public func modifyRequest(request: NimbusRequest) {
        // This method is present to maintain backward compatibility, but the async counterpart is used instead.
    }
    
    public func didCompleteNimbusRequest(with ad: NimbusAd) {
        logger.log("Completed NimbusRequest for InMobi.", level: .debug)
    }
    
    public func didFailNimbusRequest(with error: NimbusError) {
        logger.log("Failed NimbusRequest for InMobi", level: .error)
    }
    
    func renderInfo(for ad: NimbusAd) -> (any NimbusRenderInfo)? {
        guard ad.network == ThirdPartyDemandNetwork.inmobi.rawValue else {
            return nil
        }

        return NimbusInMobiRenderInfo(placementId: placementId)
    }
}
