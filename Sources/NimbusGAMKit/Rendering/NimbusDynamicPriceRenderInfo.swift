//
//  NimbusDynamicPriceRenderInfo.swift
//  NimbusGAMKit
//
//  Created on 23/04/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusCoreKit

/// :nodoc:
struct NimbusDynamicPriceRenderInfo: Codable {
    let auctionId: String
    let googleClickEventUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case auctionId = "na_id"
        case googleClickEventUrl = "ga_click"
    }
    
    init(auctionId: String, googleClickEventUrl: URL) {
        self.auctionId = auctionId
        self.googleClickEventUrl = googleClickEventUrl
    }
    
    init?(info: String?) {
        guard let data = info?.data(using: .utf8) else {
            Nimbus.shared.logger.log(
                "Unable to encode render info string to NimbusDynamicPriceRenderInfo",
                level: .error
            )
            return nil
        }
        
        do {
            self = try JSONDecoder().decode(NimbusDynamicPriceRenderInfo.self, from: data)
        } catch {
            Nimbus.shared.logger.log("\(error)", level: .error)
            return nil
        }
    }
}
