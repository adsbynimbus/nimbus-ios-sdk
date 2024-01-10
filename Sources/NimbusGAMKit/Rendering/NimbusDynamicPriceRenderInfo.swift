//
//  NimbusDynamicPriceRenderInfo.swift
//  NimbusGAMKit
//
//  Created on 23/04/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation

/// :nodoc:
struct NimbusDynamicPriceRenderInfo: Decodable {
    let auctionId: String
    let googleClickEventUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case auctionId = "na_id"
        case googleClickEventUrl = "ga_click"
    }
}
