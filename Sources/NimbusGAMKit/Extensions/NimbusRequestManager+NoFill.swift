//
//  NimbusRequestManager+NoFill.swift
//  Nimbus
//  Created on 2/21/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusRequestKit
import GoogleMobileAds

public extension NimbusRequestManager {
    func notifyError(ad: NimbusAd, error: Error) {
        let errorCode = RequestError(_nsError: (error as NSError)).code
        
        if errorCode == .noFill {
            notifyLoss(ad: ad, auctionData: NimbusAuctionData(auctionPrice: "-1"))
        }
    }
}
