//
//  NimbusVungleRequest.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 18/05/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

import Foundation

/// :nodoc:
@available(*, deprecated, message: "This protocol is no longer used and conforming to it will have no effect.")
public protocol NimbusVungleRequestType {
    var isInitialized: Bool { get }
    
    func start(withAppId appID: String) throws
    func currentSuperToken() -> String
    func setLoggingEnabled(_ enabled: Bool)
}

/// :nodoc:
@available(*, deprecated, message: "This class is no longer used and inheriting it will have no effect.")
public final class NimbusVungleRequest: NimbusVungleRequestType {
    
    public var isInitialized: Bool { false }
        
    public init() {}
    
    public func start(withAppId appID: String) throws {}

    public func currentSuperToken() -> String { "" }
    
    public func setLoggingEnabled(_ enabled: Bool) {}
}
