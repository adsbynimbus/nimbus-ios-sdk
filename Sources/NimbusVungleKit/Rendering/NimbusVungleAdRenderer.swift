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
        
    public init() {}
    
    public func render(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        container: UIView,
        adPresentingViewController: UIViewController?,
        delegate: AdControllerDelegate
    ) -> AdController {
        NimbusVungleAdController(
            ad: ad,
            container: container,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adPresentingViewController: adPresentingViewController
        )
    }
}

