//
//  NimbusRequest+Moloco.swift
//  Nimbus
//  Created on 5/28/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusRequestKit

public extension NimbusRequest {
    /**
     Include Moloco bidding in the current request.
     
     Example including Moloco in a banner request:
     ```swift
     NimbusRequest.forBannerAd("position").withMoloco(adUnitId: "adUnit")
     ```
     
     - Parameters:
     - adUnitId: Moloco ad unit id
     
     - Returns: NimbusRequest
     */
    @discardableResult
    func withMoloco(adUnitId: String) -> NimbusRequest {
        if interceptors == nil { interceptors = [] }
        interceptors?.append(
            NimbusMolocoRequestInterceptor(adUnitId: adUnitId)
        )
        return self
    }
}
