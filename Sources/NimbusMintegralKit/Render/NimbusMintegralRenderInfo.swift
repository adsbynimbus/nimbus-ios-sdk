//
//  NimbusMintegralRenderInfo.swift
//  Nimbus
//  Created on 11/5/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusCoreKit

struct NimbusMintegralRenderInfo: Codable, NimbusRenderInfo {
    let adUnitId: String
    let placementId: String?
}
