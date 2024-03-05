//
//  GAMBannerView+Nimbus.swift
//  Nimbus
//  Created on 2/26/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import GoogleMobileAds
import NimbusKit

extension GAMBannerView {
    private static var nimbusBannerAdKey: Void?
    private static var nimbusBannerProxyKey: Void?
    
    private var nimbusBannerAd: NimbusDynamicPriceBannerAd? {
        get {
            objc_getAssociatedObject(
                self, 
                &Self.nimbusBannerAdKey
            ) as? NimbusDynamicPriceBannerAd
        }
        set {
            objc_setAssociatedObject(
                self,
                &Self.nimbusBannerAdKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    private var nimbusBannerProxy: NimbusDynamicPriceBannerProxy? {
        get {
            objc_getAssociatedObject(
                self,
                &Self.nimbusBannerProxyKey
            ) as? NimbusDynamicPriceBannerProxy
        }
        set {
            objc_setAssociatedObject(
                self,
                &Self.nimbusBannerProxyKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    /// This method initializes nimbus dynamic price for this GAMBannerView instance.
    /// Make sure to call applyDynamicPrice() before any other method below.
    /// - Parameters:
    ///     - ad: NimbusAd to render if Nimbus wins
    ///     - requestManager: A request manager instance
    ///     - delegate: pass GADBannerViewDelegate if you want to receive delegate messages about this banner. Do NOT set `bannerView.delegate` property yourself as it would override our proxy, resulting in Nimbus Dynamic Price not working correctly.
    public func applyDynamicPrice(
        requestManager: NimbusRequestManager = NimbusRequestManager(),
        delegate: GADBannerViewDelegate? = nil,
        ad: NimbusAd? = nil
    ) {
        nimbusBannerProxy = NimbusDynamicPriceBannerProxy(
            requestManager: requestManager,
            clientDelegate: delegate
        )
        self.delegate = nimbusBannerProxy
                
        initBannerAd(ad: ad)
    }
    
    /// This method should be used instead of GAMBannerView.load() and only if the ad is loaded
    /// using GAMBannerView, not GADAdLoader. loadDynamicPrice() sets up dynamic price targeting and
    /// calls GAMBannerView.load() at the end.
    /// - Parameters:
    ///     - ad: NimbusAd to render if Nimbus wins
    ///     - gamRequest: Instance of GAMRequest
    ///     - mapping: Default is `NimbusGAMLinearPriceMapping.banner()`
    public func loadDynamicPrice(
        gamRequest: GAMRequest,
        ad: NimbusAd? = nil,
        mapping: NimbusGAMLinearPriceMapping = .banner()
    ) {
        guard let _ = validateProxy() else { return }
        
        if !gamRequest.hasDynamicPrice {
            ad?.applyDynamicPrice(into: gamRequest, mapping: mapping)
        }

        initBannerAd(ad: ad)
        load(gamRequest)
    }
    
    /// Call this method inside the `paidEventHandler` property.
    /// - Parameters:
    ///     - adValue: instance of GADAdValue
    public func updatePrice(_ adValue: GADAdValue) {
        nimbusBannerAd?.updatePrice(adValue)
    }
    
    /// Call this method when you receive a GADAppEventDelegate message of
    /// `adView(banner:didReceiveAppEvent:withInfo:)` to see whether Nimbus
    /// can handle the given app event.
    /// - Parameters:
    ///     - name: The event name
    ///     - info: The event information
    /// - Returns: True if Nimbus will render the ad, false otherwise
    @discardableResult
    public func handleEventForNimbus(name: String, info: String?) -> Bool {
        guard validate() else { return false }
        return nimbusBannerAd?.handleEventForNimbus(name: name, info: info) ?? false
    }
    
    private func validate() -> Bool {
        guard let _ = validateProxy() else { return false }
        guard let _ = nimbusBannerAd else {
            Nimbus.shared.logger.log("NimbusDynamicPriceBannerAd was not initialized", level: .error)
            return false
        }
        
        return true
    }
    
    private func validateProxy() -> NimbusDynamicPriceBannerProxy? {
        guard let nimbusBannerProxy, delegate is NimbusDynamicPriceBannerProxy else {
            Nimbus.shared.logger.log("Custom GAMBannerView.delegate was set while using Nimbus Dynamic Price implementation. Please pass your delegate in GAMBannerView.applyDynamicPrice instead.", level: .error)
            return nil
        }
        
        return nimbusBannerProxy
    }
    
    private func initBannerAd(ad: NimbusAd?) {
        guard let proxy = validateProxy() else { return }
        guard let ad else {
            // To make sure there's no stale nimbus-rendered ad
            nimbusBannerAd = nil
            return
        }
        
        nimbusBannerAd = NimbusDynamicPriceBannerAd(
            ad: ad,
            requestManager: proxy.requestManager,
            bannerView: self
        )
        proxy.nimbusDelegate = nimbusBannerAd
    }
}
