//
//  NimbusVungleAdRenderer.swift
//  NimbusVungleKit
//
//  Created on 13/09/22.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit
import UIKit
import VungleAdsSDK

public protocol NimbusVungleNativeAdViewType: UIView {
    var mediaView: MediaView { get set }
    var iconImageView: UIImageView? { get set }
    var clickableViews: [UIView]? { get }
}

public protocol NimbusVungleAdRendererDelegate: AnyObject {
    /**
     The UIView returned from this method should have all of the data set from the native ad
     on children views such as the call to action, image data, title, privacy icon etc.
     The view returned from this method should not be attached to the container passed in as
     it will be attached at a later time during the rendering process.
     
     - Parameters:
     - container: The container the layout will be attached to
     - nativeAd: The Vungle native ad with the relevant ad information
     
     - Returns: Your custom UIView (NimbusVungleNativeAdViewType) that will be attached to the container
     */
    func customViewForRendering(container: UIView, nativeAd: VungleNative) -> NimbusVungleNativeAdViewType
}

public final class NimbusVungleAdRenderer: AdRenderer {
    
    /// Implement this delegate if you want to display native ads
    public weak var adRendererDelegate: NimbusVungleAdRendererDelegate?
    
    /// Controls whether the creative scaling is enabled for static ads with dimensions
    /// :nodoc
    @available(*, deprecated, message: "No-op. Creative scaling is always enabled. Set width/height constraints to the ad container to prevent any scaling")
    public var creativeScalingEnabled = true
    
    public init() {}
    
    public func render(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        container: UIView,
        adPresentingViewController: UIViewController?,
        delegate: (any AdControllerDelegate)?
    ) -> AdController {
        let adController = NimbusVungleAdController(
            ad: ad,
            container: container,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adPresentingViewController: adPresentingViewController,
            isBlocking: false,
            isRewarded: false,
            adRendererDelegate: adRendererDelegate
        )
        
        // Ensure that the ad load begins AFTER the publisher has had a chance to retrieve the ad controller
        DispatchQueue.main.async {
            adController.load()
        }
        
        return adController
    }
    
    public func renderBlocking(
        ad: NimbusAd,
        isRewarded: Bool,
        companionAd: NimbusCompanionAd?,
        adPresentingViewController: UIViewController,
        delegate: (any AdControllerDelegate)?
    ) -> AdController {
        let adController = NimbusVungleAdController(
            ad: ad,
            container: adPresentingViewController.nimbusContainer,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adPresentingViewController: adPresentingViewController,
            isBlocking: true,
            isRewarded: isRewarded,
            adRendererDelegate: adRendererDelegate
        )
        
        // Ensure that the ad load begins AFTER the publisher has had a chance to retrieve the ad controller
        DispatchQueue.main.async {
            adController.load()
        }
        
        return adController
    }
}

