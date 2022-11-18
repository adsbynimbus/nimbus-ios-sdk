//
//  NimbusLogLevel+FBAdLogLevel.swift
//  NimbusRequestFANKit
//
//  Created by Inder Dhir on 2/3/20.
//  Copyright © 2020 Timehop. All rights reserved.
//

import NimbusRequestKit
import FBAudienceNetwork

public extension NimbusLogLevel {
    var fanLogLevel: FBAdLogLevel {
        switch self {
        case .off: return .none
        case .error: return .error
        case .debug: return .debug
        case .info: return .verbose
        }
    }
}
