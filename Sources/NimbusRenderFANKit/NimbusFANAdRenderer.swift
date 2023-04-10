//
//  FANAdRenderer.swift
//  NimbusRenderKit
//
//  Created by Inder Dhir on 1/30/20.
//  Copyright © 2020 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import FBAudienceNetwork

public protocol NimbusFANAdRendererDelegate: AnyObject {
    /**
     The UIView returned from this method should have all of the data set from the native ad
     on children views such as the call to action, image data, title, privacy icon etc.
     The view returned from this method should not be attached to the container passed in as
     it will be attached at a later time during the rendering process.

     - Parameters:
     - container: The container the layout will be attached to
     - nativeAd: The Facebook native ad with the relevant ad information

     - Returns: Your custom UIView that will be attached to the container
     */
    func customViewForRendering(container: UIView, nativeAd: FBNativeAd) -> UIView
}

public final class NimbusFANAdRenderer: AdRenderer {

    public weak var adRendererDelegate: NimbusFANAdRendererDelegate?

    public init() {}

    public func render(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        container: UIView,
        adPresentingViewController: UIViewController?,
        delegate: AdControllerDelegate
    ) -> AdController {
        NimbusFANAdController(
            ad: ad,
            container: container,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adRendererDelegate: adRendererDelegate,
            adPresentingViewController: adPresentingViewController
        )
    }
}
