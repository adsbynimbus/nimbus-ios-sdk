//
//  NimbusRequestManager+NoFill.swift
//  Nimbus
//  Created on 2/21/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusRequestKit

public extension NimbusRequestManager {
    func notifyNoFill(ad: NimbusAd) {
        notifyLoss(ad: ad, auctionData: NimbusAuctionData(auctionPrice: "-1"))
    }
}
