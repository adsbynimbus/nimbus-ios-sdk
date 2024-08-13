//
//  NimbusMobileFuseAdRenderer.swift
//  NimbusMobileFuseKit
//
//  Created on 9/8/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusCoreKit

public final class NimbusMobileFuseAdRenderer: AdRenderer {
    public init() {}
    
    public func render(ad: NimbusAd,
                companionAd: NimbusCompanionAd?,
                container: UIView,
                adPresentingViewController: UIViewController?,
                delegate: AdControllerDelegate) -> AdController {
        let adController = NimbusMobileFuseAdController(
            ad: ad,
            container: container,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            isBlocking: false,
            adPresentingViewController: adPresentingViewController
        )
        
        // Ensure that the ad load begins AFTER the publisher has had a chance to retrieve the ad controller
        DispatchQueue.main.async {
            adController.load()
        }
        
        return adController
    }
    
    public func renderBlocking(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        adPresentingViewController: UIViewController,
        delegate: any AdControllerDelegate
    ) -> any AdController {
        let adController = NimbusMobileFuseAdController(
            ad: ad,
            container: adPresentingViewController.nimbusContainer,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            isBlocking: true,
            adPresentingViewController: adPresentingViewController
        )
        
        // Ensure that the ad load begins AFTER the publisher has had a chance to retrieve the ad controller
        DispatchQueue.main.async {
            adController.load()
        }
        
        return adController
    }
}
