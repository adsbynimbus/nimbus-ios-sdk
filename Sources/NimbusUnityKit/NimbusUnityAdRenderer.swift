//
//  NimbusUnityAdRenderer.swift
//  NimbusUnityKit
//
//  Created by Inder Dhir on 6/2/21.
//  Copyright © 2021 Timehop. All rights reserved.
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
        NimbusUnityAdController(
            ad: ad,
            container: container as! (UIView & VisibilityTrackable),
            volume: 0,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adPresentingViewController: adPresentingViewController
        )
    }
}
