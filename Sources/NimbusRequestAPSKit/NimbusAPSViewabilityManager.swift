//
//  NimbusAPSViewabilityManager.swift
//  NimbusRequestAPSKit
//
//  Created on 2/7/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import DTBiOSSDK

final class NimbusAPSViewabilityManager {
    
    private enum ViewabilityState: Equatable {
        case unset
        case enabled(name: String, version: String?)
        case disabled
    }
    
    private var state = ViewabilityState.unset
    
    init() {}
    
    func setup(for request: NimbusRequest) {
        let omName = getOMName(for: request)
        let omVersion = getOMVersion(for: request)

        let isViewabilityEnabled = omName != nil
        guard needsStateUpdate(
            viewabilityEnabled: isViewabilityEnabled,
            omName: omName,
            omVersion: omVersion
        ) else { return }

        if isViewabilityEnabled, let omName {
            state = .enabled(name: omName, version: omVersion)
            
            enableViewabilityforAPS(name: omName, version: omVersion)
        } else {
            state = .disabled
            
            disableViewabilityforAPS()
        }
    }
    
    private func getOMName(for request: NimbusRequest) -> String? {
        request.source?.extensions?["omidpn"]?.value as? String
    }
    
    private func getOMVersion(for request: NimbusRequest) -> String? {
        request.source?.extensions?["omidpv"]?.value as? String
    }
    
    private func needsStateUpdate(
        viewabilityEnabled: Bool,
        omName: String?,
        omVersion: String?
    ) -> Bool {
        if viewabilityEnabled {
            switch state {
            case let .enabled(name, version):
                return omName != name || omVersion != version
            default:
                return true
            }
        } else {
            return state != .disabled
        }
    }
    
    private func enableViewabilityforAPS(name: String, version: String?) {
        DTBAds.sharedInstance().addCustomAttribute("omidPartnerName", value: name)
        if let version {
            DTBAds.sharedInstance().addCustomAttribute("omidPartnerVersion", value: version)
        }
    }
    
    private func disableViewabilityforAPS() {
        DTBAds.sharedInstance().removeCustomAttribute("omidPartnerName")
        DTBAds.sharedInstance().removeCustomAttribute("omidPartnerVersion")
    }
}
