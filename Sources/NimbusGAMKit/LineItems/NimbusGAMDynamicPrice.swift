//
//  NimbusGAMDynamicPrice.swift
//  NimbusGAMKit
//
//  Created on 10/21/20.
//  Copyright © 2020 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit
import GoogleMobileAds

/// Nimbus Dynamice Price implementation for GAM which applies keywords to a `GADRequest`
@available(*, deprecated, message: "Use NimbusAd.applyDynamicPrice extension instead")
public class NimbusGAMDynamicPrice {
    
    /// Label for the custom event set up in the GAM dashboard
    private static let eventLabel = "NimbusCustomEvent"
    
    /// Delegate for Nimbus requests
    public weak var requestDelegate: NimbusRequestManagerDelegate?
    
    /// The GAM request to add keywords to
    private weak var request: GAMRequest?
    
    /// A provider for mapping a bid to keywords to apply to the MPAdView
    private let mapping: NimbusDynamicPriceMapping?
    
    /**
     Constructs a new `NimbusGAMDynamicPrice`
     
     - Parameters:
     - request: The GAM request to apply keywords to
     - mapping: A provider for mapping a bid to keywords to apply to the GAM request
     */
    public init(request: GAMRequest, mapping: NimbusDynamicPriceMapping? = nil) {
        self.request = request
        self.mapping = mapping
    }
}

/// :nodoc:
extension NimbusGAMDynamicPrice: NimbusRequestManagerDelegate {
    
    public func didCompleteNimbusRequest(request: NimbusRequest, ad: NimbusAd) {
        let mapping: NimbusDynamicPriceMapping
        if let pubMapping = self.mapping {
            mapping = pubMapping
        } else {
            mapping = ad.isInterstitial ?
                NimbusGAMLinearPriceMapping.fullscreen() : .banner()
        }
        
        guard let keywords = mapping.getKeywords(ad: ad) else {
            Nimbus.shared.logger.log("No keywords to add for GAM", level: .error)
            requestDelegate?.didCompleteNimbusRequest(request: request, ad: ad)
            return
        }
        
        Nimbus.shared.logger.log(
            "Inserting keywords `\(keywords)` for GAM request `\(self.request?.description ?? "Unknown")`",
            level: .debug
        )
        
        guard let gamRequest = self.request else { return }
        ad.applyDynamicPrice(into: gamRequest, keywords: keywords)
    
        requestDelegate?.didCompleteNimbusRequest(request: request, ad: ad)
    }
    
    public func didFailNimbusRequest(request: NimbusRequest, error: NimbusError) {
        switch error as? NimbusRequestError {
        case .noAdFill:
            Nimbus.shared.logger.log(
                "No bid for GAM request: `\(self.request?.description ?? "Unknown")`",
                level: .debug
            )
        default: break
        }
        
        requestDelegate?.didFailNimbusRequest(request: request, error: error)
    }
}
