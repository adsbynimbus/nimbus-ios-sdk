//
//  InMobiRequestBridge.swift
//  Nimbus
//  Created on 7/31/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import InMobiSDK
import NimbusCoreKit

enum NimbusInMobiRequestError: NimbusError {
    case couldntFetchBidToken
    
    var errorDescription: String? {
        switch self {
        case .couldntFetchBidToken:
            return "Couldn't fetch InMobi bid token"
        }
    }
}

public class InMobiRequestBridge {
    public init() {}
    
    public static let extras: [String: Any] = [
        "tp": "c_nimbus",
        "tp-ver": Nimbus.shared.version
    ]
    
    /// Not sure if IMSdk is thread safe
    @MainActor
    public var bidToken: String {
        get throws {
            guard let token = IMSdk.getTokenWithExtras(Self.extras, andKeywords: nil) else {
                throw NimbusInMobiRequestError.couldntFetchBidToken
            }
            
            return token
        }
    }
    
    @MainActor
    public func set(coppa: Bool?) {
        guard let coppa else { return }
        
        IMSdk.setIsAgeRestricted(coppa)
    }
}
