//
//  NimbusRequest+Mintegral.swift
//  Nimbus
//  Created on 11/5/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusRequestKit

public extension NimbusRequest {
    /**
     Include Mintegral bidding in the current request.
     
     Example including Mintegral in a banner request:
     ```swift
     NimbusRequest.forBannerAd("position").withMintegral(adUnitId: "adUnit", placementId: "placement")
     ```
     
     - Parameters:
     - adUnitId: Mintegral ad unit id
     - placementId: Mintegral placement id
     
     - Returns: NimbusRequest
     */
    @discardableResult
    func withMintegral(adUnitId: String, placementId: String? = nil) -> NimbusRequest {
        if interceptors == nil { interceptors = [] }
        interceptors?.append(
            NimbusMintegralRequestInterceptor(adUnitId: adUnitId, placementId: placementId)
        )
        return self
    }
}
