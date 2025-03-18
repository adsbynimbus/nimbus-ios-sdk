//
//  NimbusMintegralAdRenderer.swift
//  Nimbus
//  Created on 10/30/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusCoreKit
import MTGSDK

public protocol NimbusMintegralNativeAdViewType: UIView {    
    /**
     Array of clickable views.
     
     It's recommended to implement this as a computed property, making
     it very easy to return the views you consider clickable, for instance:
     ```swift
     class MyNativeView: UIView, NimbusMintegralNativeAdViewType {
        let mediaView: MTGMediaView
        let installButton: UIButton
        
        var clickableViews: [mediaView, installButton]
     }
     ```
     */
    var clickableViews: [UIView] { get }
    
    /**
     Mintegral Media View.
     
     - Please DO NOT call `setMediaSourceWith(campaign, unitId: adUnitId)` as we call it upon retrieving the view.
     - Please DO NOT set delegate as we will override it in order to track impression (and possibly other) events.
     All events will be forwarded as a NimbusEvent that you can listen to.
     */
    var mediaView: MTGMediaView { get }
}

public protocol NimbusMintegralAdRendererDelegate: AnyObject {
    /**
     The UIView returned from this method should have all of the data set from the native ad
     on children views such as the call to action, image data, title, privacy icon etc.
     The view returned from this method should not be attached to the container passed in as
     it will be attached at a later time during the rendering process.
     
     NOTE: DO NOT set MTGMediaView.delegate. Nimbus uses this delegate and forwards events as NimbusEvent. You may
     listen set AdController.delegate and listen to didReceiveNimbusEvent() and didReceiveNimbusError() instead.
     
     - Parameters:
     - container: The container the layout will be attached to
     - campaign: The Mintegral campaign with the relevant ad information
     
     - Returns: Your custom UIView. DO NOT attach the view to the hierarchy yourself.
     */
    func nativeAdViewForRendering(container: UIView, campaign: MTGCampaign) -> NimbusMintegralNativeAdViewType
}

public final class NimbusMintegralAdRenderer: AdRenderer {
    /// Implement this delegate if you want to display native ads
    public weak var adRendererDelegate: NimbusMintegralAdRendererDelegate?
    
    public init() {}
    
    public func render(ad: NimbusAd,
                companionAd: NimbusCompanionAd?,
                container: UIView,
                adPresentingViewController: UIViewController?,
                delegate: (any AdControllerDelegate)?) -> AdController {
        
        let adController = NimbusMintegralAdController(
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
        let adController = NimbusMintegralAdController(
            ad: ad,
            container: adPresentingViewController.nimbusContainer,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            isBlocking: true,
            isRewarded: isRewarded,
            adPresentingViewController: adPresentingViewController
        )
        
        // Ensure that the ad load begins AFTER the publisher has had a chance to retrieve the ad controller
        Task { @MainActor in adController.load() }
        
        return adController
    }
}
