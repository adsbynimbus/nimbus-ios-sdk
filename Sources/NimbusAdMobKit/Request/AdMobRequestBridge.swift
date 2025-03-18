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
        
        GADMobileAds
            .sharedInstance()
            .requestConfiguration.tagForChildDirectedTreatment = NSNumber(booleanLiteral: coppa)
    }
    
    public func generateSignal(request: GADSignalRequest) async throws -> String {
        try await GADMobileAds.generateSignal(request).signalString
    }
}
