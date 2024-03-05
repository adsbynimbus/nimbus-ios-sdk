//
//  GADInterstitialAd+Nimbus.swift
//  NimbusGAMKit
//  Created on 2/16/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds
import NimbusCoreKit

extension GADInterstitialAd {
    private static var nimbusAdKey: Void?

    private var nimbusInterstitialAd: NimbusDynamicPriceInterstitialAd? {
        get {
            objc_getAssociatedObject(self, &Self.nimbusAdKey) as? NimbusDynamicPriceInterstitialAd
        }
        set {
            objc_setAssociatedObject(self, &Self.nimbusAdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// This method initializes nimbus dynamic price for this GADInterstitialAd instance.
    /// Make sure to call applyDynamicPrice() before any other method below.
    /// - Parameters:
    ///     - ad: NimbusAd to render if Nimbus wins
    ///     - requestManager: A request manager instance
    ///     - delegate: pass GADFullScreenContentDelegate if you want to receive delegate messages about this interstitial. Do NOT set `fullScreenContentDelegate` property yourself as it would override our proxy, resulting in Nimbus Dynamic Price not working correctly.
    public func applyDynamicPrice(
        ad: NimbusAd,
        requestManager: NimbusRequestManager = NimbusRequestManager(),
        delegate: GADFullScreenContentDelegate? = nil
    ) {
        nimbusInterstitialAd = NimbusDynamicPriceInterstitialAd(
            ad: ad,
            requestManager: requestManager,
            clientDelegate: delegate,
            gadInterstitialAd: self
        )
        fullScreenContentDelegate = nimbusInterstitialAd
    }
    
    /// Call this method inside the `paidEventHandler` property.
    /// - Parameters:
    ///     - adValue: instance of GADAdValue
    public func updatePrice(_ adValue: GADAdValue) {
        nimbusInterstitialAd?.updatePrice(adValue)
    }
    
    /// Call this method when you receive a GADAppEventDelegate message of
    /// `interstitialAd(interstitialAd:didReceiveAppEvent:withInfo:)` to see whether Nimbus
    /// can handle the given app event.
    /// - Parameters:
    ///     - name: The event name
    ///     - info: The event information
    /// - Returns: True if Nimbus will render the ad, false otherwise
    @discardableResult
    public func handleEventForNimbus(name: String, info: String?) -> Bool {
        guard validate() else { return false }
        return nimbusInterstitialAd?.handleEventForNimbus(name: name, info: info) ?? false
    }
    
    /// This method calls GADInterstitialAd.present(fromRootViewController:) while making sure
    /// the same controller is used for Nimbus rendering (if Nimbus wins).
    ///
    /// Must be called on the main thread. You may call this method even if dynamic price
    /// wasn't applied, in which case, it will only call google's present() method.
    ///
    /// - Parameters:
    ///     - rootViewController: A view controller that should present the interstitial ad. We'll detect a root view controller if this parameter is nil
    public func presentDynamicPrice(fromRootViewController: UIViewController?) {
        guard let controller = fromRootViewController ?? Self.detectedRootViewController else {
            Nimbus.shared.logger.log("\(#function) did not receive a rootViewController and it failed to detect rootViewController on its own", level: .error)
            return
        }
        guard let _ = nimbusInterstitialAd else {
            present(fromRootViewController: controller)
            return
        }
        guard validateDelegate() else { return }
        
        nimbusInterstitialAd?.rootViewController = controller
        
        // setting it right before present() so that we can detect if a user
        // doesn't call this presentation method by observing this value
        // in delegate: NimbusDynamicPriceInterstitialAd.adWillRender()
        nimbusInterstitialAd?.didPresentGoogleController = true
        present(fromRootViewController: controller)

        self.nimbusInterstitialAd?.present()
    }
    
    private func validate() -> Bool {
        guard let _ = nimbusInterstitialAd else {
            Nimbus.shared.logger.log("GADInterstitialAd.applyDynamicPrice was not called", level: .error)
            return false
        }
        
        return validateDelegate()
    }
    
    private func validateDelegate() -> Bool {
        guard fullScreenContentDelegate is NimbusDynamicPriceInterstitialAd else {
            Nimbus.shared.logger.log("Custom GADInterstitialAd.fullScreenContentDelegate was set while using Nimbus Dynamic Price implementation. Please pass your delegate in GADInterstitialAd.applyDynamicPrice instead.", level: .error)
            return false
        }
        
        return true
    }
    
    private static var detectedRootViewController: UIViewController? {
        var rootViewController: UIViewController?
        
        if #available(iOS 15.0, *) {
            let allScenes = UIApplication.shared.connectedScenes
            let scene = allScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
            rootViewController = scene?.keyWindow?.rootViewController
        } else {
            let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            rootViewController = (keyWindow ?? UIApplication.shared.windows.first)?.rootViewController
        }
        
        return rootViewController?.topMostViewController
    }
}

private extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController
        }
        
        return self
    }
}
