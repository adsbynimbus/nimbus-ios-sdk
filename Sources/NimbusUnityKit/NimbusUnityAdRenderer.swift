//
//  NimbusUnityAdRenderer.swift
//  NimbusUnityKit
//
//  Created on 6/2/21.
//  Copyright © 2021 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit
import UIKit

public final class NimbusUnityAdRenderer: AdRenderer {

    public init() {}

    public func render(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        container: UIView,
        adPresentingViewController: UIViewController?,
        delegate: AdControllerDelegate
    ) -> AdController {
        let adController = NimbusUnityAdController(
            ad: ad,
            container: container,
            volume: 0,
            logger: Nimbus.shared.logger,
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
