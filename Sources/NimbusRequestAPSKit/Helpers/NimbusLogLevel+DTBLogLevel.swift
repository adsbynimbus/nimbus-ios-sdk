//
//  NimbusLogLevel+DTBLogLevel.swift
//  NimbusRequestAPSKit
//
//  Created by Inder Dhir on 2/3/20.
//  Copyright © 2020 Timehop. All rights reserved.
//

import DTBiOSSDK
import NimbusCoreKit

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
