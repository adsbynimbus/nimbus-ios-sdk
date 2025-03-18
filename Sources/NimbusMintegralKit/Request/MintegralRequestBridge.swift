//
//  MintegralRequestBridge.swift
//  Nimbus
//  Created on 3/7/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import MTGSDK
import MTGSDKBidding

public class MintegralRequestBridge {
    public init() {}
    
    // Mintegral singleton should only be accessed from the main thread as their documentation recommends.
    @MainActor public func set(coppa: Bool?) {
        guard let coppa else { return }
        
        MTGSDK.sharedInstance().coppa = coppa ? .yes : .no
    }
    
    // Mintegral singleton should only be accessed from the main thread as their documentation recommends.
    @MainActor public var tokenData: [String: String] {
        [
            "buyeruid": MTGBiddingSDK.buyerUID(),
            "sdkv": MTGSDK.sdkVersion()
        ]
    }
}
