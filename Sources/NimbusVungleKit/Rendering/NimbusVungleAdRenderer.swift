//
//  NimbusVungleAdRenderer.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 13/09/22.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import UIKit

public final class NimbusVungleAdRenderer: AdRenderer {
        
    /// Controls whether the creative scaling is enabled for static ads with dimensions
    /// :nodoc
    public var creativeScalingEnabled = true
    
    public init() {}
    
    public func render(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        container: UIView,
        adPresentingViewController: UIViewController?,
        delegate: AdControllerDelegate
    ) -> AdController {
        let adController = NimbusVungleAdController(
            ad: ad,
            container: container,
            logger: Nimbus.shared.logger,
            creativeScalingEnabled: creativeScalingEnabled,
            delegate: delegate,
            adPresentingViewController: adPresentingViewController
        )
        
        // Ensure that the ad load begins AFTER the publisher has had a chance to retrieve the ad controller
        DispatchQueue.main.async {
            adController.load()
        }
        
        return adController
    }
}

