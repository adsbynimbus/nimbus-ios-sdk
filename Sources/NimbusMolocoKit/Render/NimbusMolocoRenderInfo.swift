//
//  NimbusMolocoRenderInfo.swift
//  Nimbus
//  Created on 5/28/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusCoreKit

public struct NimbusMolocoRenderInfo: Codable, NimbusRenderInfo {
    let adUnitId: String
    
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
    }
}
