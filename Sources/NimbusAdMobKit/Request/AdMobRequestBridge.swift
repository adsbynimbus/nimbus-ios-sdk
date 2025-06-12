//
//  AdMobRequestBridge.swift
//  Nimbus
//  Created on 3/7/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds

public class AdMobRequestBridge {
    public init() {}
    
    public func set(coppa: Bool?) {
        guard let coppa else { return }
        
        MobileAds
            .shared
            .requestConfiguration.tagForChildDirectedTreatment = NSNumber(booleanLiteral: coppa)
    }
    
    public func generateSignal(request: SignalRequest) async throws -> String {
        try await MobileAds.generateSignal(request).signal
    }
}
