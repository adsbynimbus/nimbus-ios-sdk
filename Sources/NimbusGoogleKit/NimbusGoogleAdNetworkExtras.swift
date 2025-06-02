//
//  NimbusGoogleAdNetworkExtras.swift
//  NimbusGoogleKit
//
//  Created on 6/29/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds

public final class NimbusGoogleAdNetworkExtras: NSObject, GADAdNetworkExtras {
    private enum ExtrasError: LocalizedError {
        case positionIsEmpty
        
        var errorDescription: String? {
            "Position cannot be empty"
        }
    }
    
    public let position: String
    
    public init(position: String) throws {
        if position.isEmpty {
            throw ExtrasError.positionIsEmpty
        }
        self.position = position
    }
}
