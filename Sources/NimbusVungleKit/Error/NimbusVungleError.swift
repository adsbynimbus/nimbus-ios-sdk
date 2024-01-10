//
//  NimbusVungleError.swift
//  NimbusVungleKit
//
//  Created on 12/10/22.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit

public enum NimbusVungleError: NimbusError, Equatable {
    case sdkNotInitialized
    case sdkAlreadyInitialized

    case failedToStartAd(type: String? = nil, message: String)
    case failedToLoadAd(type: String? = nil, message: String)
    case failedToPresentAd(type: String? = nil, message: String)
    
    public var errorDescription: String? {
        switch self {
        case .sdkNotInitialized:
            return "Vungle SDK not initialized"
        case .sdkAlreadyInitialized:
            return "Vungle SDK already initialized"
            
        case let .failedToStartAd(type, message):
            return "Vungle failed to start \(getAdTypeMessage(type)) \(message)"
        case let .failedToLoadAd(type, message):
            return "Vungle failed to load \(getAdTypeMessage(type)) \(message)"
        case let .failedToPresentAd(type, message):
            return "Vungle failed to present \(getAdTypeMessage(type)) \(message)"
        }
    }
    
    private func getAdTypeMessage(_ type: String?) -> String {
        if let type {
            return "\(type) ad:"
        } else {
            return "ad:"
        }
    }
}
