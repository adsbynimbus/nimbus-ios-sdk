//
//  NimbusLogLevel+DTBLogLevel.swift
//  NimbusRequestAPSKit
//
//  Created on 2/3/20.
//  Copyright © 2020 Nimbus Advertising Solutions Inc. All rights reserved.
//

import DTBiOSSDK

extension NimbusLogLevel {
    var apsLogLevel: DTBLogLevel {
        switch self {
        case .off: return DTBLogLevelOff
        case .error: return DTBLogLevelError
        case .debug: return DTBLogLevelDebug
        case .info: return DTBLogLevelAll
        default: return DTBLogLevelOff
        }
    }
}
