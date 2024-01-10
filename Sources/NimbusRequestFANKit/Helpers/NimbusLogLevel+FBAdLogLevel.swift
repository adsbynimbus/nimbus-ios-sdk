//
//  NimbusLogLevel+FBAdLogLevel.swift
//  NimbusRequestFANKit
//
//  Created on 2/3/20.
//  Copyright © 2020 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit
import FBAudienceNetwork

public extension NimbusLogLevel {
    var fanLogLevel: FBAdLogLevel {
        switch self {
        case .off: return .none
        case .error: return .error
        case .debug: return .debug
        case .info: return .verbose
        default: return .none
        }
    }
}
