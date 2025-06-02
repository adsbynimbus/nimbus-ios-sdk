//
//  GADAdValue+Nimbus.swift
//  Nimbus
//  Created on 2/27/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds

extension GADAdValue {
    var nimbusPrice: String { value.multiplying(byPowerOf10: 3).stringValue }
}
