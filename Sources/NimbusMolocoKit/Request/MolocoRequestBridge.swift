//
//  MolocoRequestBridge.swift
//  Nimbus
//  Created on 5/28/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import MolocoSDK
import NimbusCoreKit

enum NimbusMolocoRequestError: NimbusError {
    case couldntFetchBidToken(error: Error?)
    
    var errorDescription: String? {
        switch self {
        case .couldntFetchBidToken(let error):
            return "Couldn't fetch Moloco bid token, error: \(String(describing: error?.localizedDescription))"
        }
    }
}

public class MolocoRequestBridge {
    public init() {}
    
    /// Moloco.shared is not thread safe and should be accessed from the main thread
    @MainActor
    public var bidToken: String {
        get async throws {
            try await withUnsafeThrowingContinuation { continuation in
                Moloco.shared.getBidToken { bidToken, error in
                    guard let bidToken, error == nil else {
                        continuation.resume(throwing: NimbusMolocoRequestError.couldntFetchBidToken(error: error))
                        return
                    }
                    
                    continuation.resume(returning: bidToken)
                }
            }
        }
    }
}
