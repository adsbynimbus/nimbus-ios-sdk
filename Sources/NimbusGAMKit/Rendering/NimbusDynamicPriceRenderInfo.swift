//
//  NimbusDynamicPriceRenderInfo.swift
//  NimbusGAMKit
//
//  Created by Victor Takai on 23/04/23.
//  Copyright © 2023 Timehop. All rights reserved.
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
