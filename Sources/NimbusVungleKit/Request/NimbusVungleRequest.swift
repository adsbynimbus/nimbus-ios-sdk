//
//  NimbusVungleRequest.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 24/09/22.
//  Copyright © 2023 Timehop. All rights reserved.
//

import VungleSDK

/// Protocol used for starting Vungle SDK
public protocol NimbusVungleRequestType {
    var isInitialized: Bool { get }
    
    func start(withAppId appID: String) throws
    func currentSuperToken() -> String
    func setLoggingEnabled(_ enabled: Bool)
}

/// Nimbus default wrapper for starting Vungle SDK
/// :nodoc:
public final class NimbusVungleRequest: NimbusVungleRequestType {
        
    public var isInitialized: Bool { sdk.isInitialized }
    
    private let sdk = VungleSDK.shared()
    
    public init() {}
    
    public func start(withAppId appID: String) throws {
        try sdk.start(withAppId: appID)
    }
    
    public func currentSuperToken() -> String {
        sdk.currentSuperToken(forPlacementID: nil, forSize: 0)
    }
    
    public func setLoggingEnabled(_ enabled: Bool) {
        sdk.setLoggingEnabled(enabled)
    }
}
