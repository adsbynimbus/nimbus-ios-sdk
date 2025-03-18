//
//  MobileFuseRequestBridge.swift
//  Nimbus
//  Created on 3/10/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import MobileFuseSDK
import NimbusCoreKit

enum NimbusMobileFuseRequestError: NimbusError {
    case couldntFetchTokenData(message: String)
    
    var errorDescription: String? {
        switch self {
        case .couldntFetchTokenData(let message):
            return "Couldn't fetch MobileFuse token data, error: \(message)"
        }
    }
}

public class MobileFuseRequestBridge {
    public init() {}
    
    public var tokenData: [String: String] {
        get async throws {
            let tokenRequest = MFBiddingTokenRequest()
            tokenRequest.partner = .MOBILEFUSE_PARTNER_NIMBUS
            
            let tokenData = await withUnsafeContinuation { continuation in
                MFBiddingTokenProvider.getTokenData(with: tokenRequest) { data in
                    continuation.resume(returning: data)
                }
            }
            
            if let error = tokenData["error"] {
                throw NimbusMobileFuseRequestError.couldntFetchTokenData(message: error)
            }
            
            return tokenData
        }
    }
}
