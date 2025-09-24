//
//  NimbusRequest+InMobi.swift
//  Nimbus
//  Created on 7/31/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusRequestKit

public extension NimbusRequest {
    /**
     Include InMobi bidding in the current request.
     
     Example including InMobi in a banner request:
     ```swift
     NimbusRequest.forBannerAd("position").withInMobi(placementId: 102656874)
     ```
     
     - Parameters:
     - placementId: InMobi placement id
     
     - Returns: NimbusRequest
     */
    @discardableResult
    func withInMobi(placementId: Int) -> NimbusRequest {
        if interceptors == nil { interceptors = [] }
        interceptors?.append(
            NimbusInMobiRequestInterceptor(placementId: Int64(placementId))
        )
        return self
    }
}
