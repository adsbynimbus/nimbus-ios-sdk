//
//  NimbusVungleError.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 12/10/22.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit

public enum NimbusVungleError: NimbusError, Equatable {
    case sdkNotInitialized
    case sdkAlreadyInitialized
    
    case failedToLoadAd(message: String)
    case failedToLoadStaticAd(type: String, message: String)
    case failedToLoadNativeAd(message: String)
    case failedToStartStaticAd(type: String, message: String)
    case failedToStartNativeAd(message: String)
    
    public var errorDescription: String? {
        switch self {
        case .sdkNotInitialized:
            return "Vungle SDK not initialized"
        case .sdkAlreadyInitialized:
            return "Vungle SDK already initialized"
            
        case let .failedToLoadAd(message):
            return "Vungle failed to load ad: \(message)"
        case let .failedToLoadStaticAd(type, message):
            return "Vungle failed to load static \(type) ad: \(message)"
        case let .failedToLoadNativeAd(message):
            return "Vungle failed to load native ad: \(message)"
        case let .failedToStartStaticAd(type, message):
            return "Vungle failed to start static \(type) ad: \(message)"
        case let .failedToStartNativeAd(message):
            return "Vungle failed to start native ad: \(message)"
        }
    }
}
