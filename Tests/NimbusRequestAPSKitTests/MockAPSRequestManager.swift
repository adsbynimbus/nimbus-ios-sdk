//
//  MockAPSRequestManager.swift
//  NimbusRequestAPSKitTests
//
//  Created by Inder Dhir on 7/18/22.
//  Copyright © 2022 Timehop. All rights reserved.
//

@testable import NimbusRequestAPSKit
import DTBiOSSDK

final class MockAPSRequestManager: APSRequestManagerType {
    
    var usPrivacyString: String? = nil
    let mockResponse: [AnyHashable: Any] = [
        "amzn_h": ["test-nimbus-url.com"],
        "amznslots": ["slotdimens"],
        "amznrdr": ["default"],
        "amznp": ["blala"],
        "amzn_b": ["blalbal"],
        "dc": ["iad"]
    ]
    
    init(sizes: [DTBAdSize]) {}
    
    func loadAdsSync(for adSizes: [DTBAdSize]) -> [[AnyHashable: Any]] {
        if adSizes.isEmpty { return [] }
        
        return [
            mockResponse
        ]
    }
}

final class MockAPSRequestManagerMultipleSizes: APSRequestManagerType {
        
    var usPrivacyString: String? = nil
    let mockResponse1: [AnyHashable: Any] = [
        "amzn_h": ["test-nimbus-url.com"],
        "amznslots": ["slotdimens"],
        "amznrdr": ["default"],
        "amznp": ["blala"],
        "amzn_b": ["blalbal"],
        "dc": ["iad"]
    ]
    let mockResponse2: [AnyHashable: Any] = [
        "amzn_h": ["test-nimbus-url.com2"],
        "amznslots": ["slot1dimens2"],
        "amznrdr": ["default2"],
        "amznp": ["blala2"],
        "amzn_b": ["blalbal2"],
        "dc": ["iad2"]
    ]
    
    init(sizes: [DTBAdSize]) {}
    
    func loadAdsSync(for adSizes: [DTBAdSize]) -> [[AnyHashable: Any]] {
        if adSizes.isEmpty { return [] }

        return [
            mockResponse1,
            mockResponse2
        ]
    }
}
