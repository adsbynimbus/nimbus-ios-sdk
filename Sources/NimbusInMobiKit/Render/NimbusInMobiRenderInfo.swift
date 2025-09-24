//
//  NimbusInMobiRenderInfo.swift
//  Nimbus
//  Created on 7/31/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusCoreKit

public struct NimbusInMobiRenderInfo: Codable, NimbusRenderInfo {
    let placementId: Int64
    
    public init(placementId: Int64) {
        self.placementId = placementId
    }
}
