//
//  NimbusInMobiAdRenderer.swift
//  Nimbus
//  Created on 7/31/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusRenderKit
import InMobiSDK

public protocol NimbusInMobiAdRendererDelegate: AnyObject {
    /**
     The UIView returned from this method should have all of the data set from the native ad
     on children views such as the call to action, image data, title, etc.
     The view returned from this method should NOT be attached to the container passed in as
     it will be attached at a later time during the rendering process.
     
     DO NOT set nativeAd.delegate! Nimbus uses it to fires events (impression, click) as NimbusEvent. You may
     set AdController.delegate and listen to didReceiveNimbusEvent() and didReceiveNimbusError() instead.
     
     - Parameters:
        - container: The container the layout will be attached to
        - nativeAd: InMobi native ad
     
     - Returns: Your custom UIView. DO NOT attach the view to the hierarchy yourself.
     */
    func nativeAdViewForRendering(container: UIView, nativeAd: IMNative) -> UIView
}

public final class NimbusInMobiAdRenderer: AdRenderer {
    
    /// Implement this delegate if you want to display native ads
    public weak var adRendererDelegate: NimbusInMobiAdRendererDelegate?
    
    public init() {}
    
    public func render(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        container: UIView,
        adPresentingViewController: UIViewController?,
        delegate: (any AdControllerDelegate)?
    ) -> any NimbusCoreKit.AdController {
        let adController = NimbusInMobiAdController(
            ad: ad,
            container: container,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            isBlocking: false,
            isRewarded: false,
            adPresentingViewController: adPresentingViewController,
            adRendererDelegate: adRendererDelegate
        )
        
        // Ensure that the ad load begins AFTER the publisher has had a chance to retrieve the ad controller
        Task { @MainActor in adController.load() }
        
        return adController
    }
    
    public func renderBlocking(
        ad: NimbusAd,
        isRewarded: Bool,
        companionAd: NimbusCompanionAd?,
        adPresentingViewController: UIViewController,
        delegate: (any AdControllerDelegate)?
    ) -> any AdController {
        let adController = NimbusInMobiAdController(
            ad: ad,
            container: adPresentingViewController.nimbusContainer,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            isBlocking: true,
            isRewarded: isRewarded,
            adPresentingViewController: adPresentingViewController,
            adRendererDelegate: adRendererDelegate
        )
        
        // Ensure that the ad load begins AFTER the publisher has had a chance to retrieve the ad controller
        Task { @MainActor in adController.load() }
        
        return adController
    }
}
