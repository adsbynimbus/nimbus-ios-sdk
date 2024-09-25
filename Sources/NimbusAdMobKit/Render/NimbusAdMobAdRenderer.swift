//
//  NimbusAdMobAdRenderer.swift
//  NimbusAdMobKit
//  Created on 9/3/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import NimbusCoreKit
import GoogleMobileAds

public protocol NimbusAdMobAdRendererDelegate: AnyObject {
    /**
     The UIView returned from this method should have all of the data set from the native ad
     on children views such as the call to action, image data, title, privacy icon etc.
     The view returned from this method should not be attached to the container passed in as
     it will be attached at a later time during the rendering process.
     
     NOTE: DO NOT set nativeAd.delegate. Nimbus uses this delegate and forwards events as NimbusEvent. You may
     listen set AdController.delegate and listen to didReceiveNimbusEvent() and didReceiveNimbusError() instead.
     
     Please set the GADNativeAdView.nativeAd property at the appropriate time, as the correct timing may vary depending on the AdChoices settings.
     
     - Parameters:
     - container: The container the layout will be attached to
     - nativeAd: The AdMob native ad with the relevant ad information
     
     - Returns: Your custom UIView (must inherit GADNativeAdView). DO NOT attach the view to the hierarchy yourself.
     */
    func nativeAdViewForRendering(container: UIView, nativeAd: GADNativeAd) -> GADNativeAdView
}

public final class NimbusAdMobAdRenderer: AdRenderer {
    /// Implement this delegate if you want to display native ads
    public weak var adRendererDelegate: NimbusAdMobAdRendererDelegate?
    
    public init() {}
    
    public func render(ad: NimbusAd,
                companionAd: NimbusCompanionAd?,
                container: UIView,
                adPresentingViewController: UIViewController?,
                delegate: AdControllerDelegate) -> AdController {
        let adController = NimbusAdMobAdController(
            ad: ad,
            container: container,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            isBlocking: false,
            adPresentingViewController: adPresentingViewController,
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
        companionAd: NimbusCompanionAd?,
        adPresentingViewController: UIViewController,
        delegate: any AdControllerDelegate
    ) -> any AdController {
        let adController = NimbusAdMobAdController(
            ad: ad,
            container: adPresentingViewController.nimbusContainer,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            isBlocking: true,
            adPresentingViewController: adPresentingViewController,
            adRendererDelegate: adRendererDelegate
        )
        
        // Ensure that the ad load begins AFTER the publisher has had a chance to retrieve the ad controller
        DispatchQueue.main.async {
            adController.load()
        }
        
        return adController
    }
}

