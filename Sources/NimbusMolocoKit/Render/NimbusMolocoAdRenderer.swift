//
//  NimbusMolocoAdRenderer.swift
//  Nimbus
//  Created on 5/28/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusRenderKit
import MolocoSDK

public protocol NimbusMolocoNativeAdViewType: UIView {
    /**
     Array of clickable views.
     
     It's recommended to implement this as a computed property, making
     it very easy to return the views you consider clickable, for instance:
     ```swift
     class MyNativeView: UIView, NimbusMolocoNativeAdViewType {
        let mediaView: UIView
        let installButton: UIButton
        
        var clickableViews: [mediaView, installButton]
     }
     ```
     */
    var clickableViews: [UIView] { get }
}

public protocol NimbusMolocoAdRendererDelegate: AnyObject {
    /**
     The UIView returned from this method should have all of the data set from the native ad
     on children views such as the call to action, image data, title, etc.
     The view returned from this method should NOT be attached to the container passed in as
     it will be attached at a later time during the rendering process.
     
     Nimbus uses MolocoNativeAd.delegate and fires events (impression, click) as NimbusEvent. You may
     listen set AdController.delegate and listen to didReceiveNimbusEvent() and didReceiveNimbusError() instead.
     
     - Parameters:
     - container: The container the layout will be attached to
     - assets: Moloco native ad assets
     
     - Returns: Your custom UIView. DO NOT attach the view to the hierarchy yourself.
     */
    func nativeAdViewForRendering(container: UIView, assets: MolocoNativeAdAssests) -> NimbusMolocoNativeAdViewType
}

public final class NimbusMolocoAdRenderer: AdRenderer {
    
    /// Implement this delegate if you want to display native ads
    public weak var adRendererDelegate: NimbusMolocoAdRendererDelegate?
    
    public init() {}
    
    public func render(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        container: UIView,
        adPresentingViewController: UIViewController?,
        delegate: (any AdControllerDelegate)?
    ) -> any NimbusCoreKit.AdController {
        let adController = NimbusMolocoAdController(
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
        let adController = NimbusMolocoAdController(
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
