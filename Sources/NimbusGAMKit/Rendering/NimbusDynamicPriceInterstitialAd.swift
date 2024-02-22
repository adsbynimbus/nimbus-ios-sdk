//
//  NimbusDynamicPriceInterstitialAd.swift
//  NimbusGAMKit
//  Created on 2/16/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import GoogleMobileAds
import NimbusKit

final class NimbusDynamicPriceInterstitialAd: NSObject {
    /// This is the publisher's original delegate. If set, we forward events to it.
    weak var clientDelegate: GADFullScreenContentDelegate?
    weak var rootViewController: UIViewController?
    weak var gadInterstitialAd: GADInterstitialAd?
    
    var gadViewController: UIViewController? { rootViewController?.presentedViewController }
    var didPresentGoogleController = false
    
    private var didPresent = false
    private let requestManager: NimbusRequestManager
    private let ad: NimbusAd
    private var isNimbusWin: Bool { renderInfo != nil }
    private var price = "-1"
    
    private var renderInfo: NimbusDynamicPriceRenderInfo?
    private let logger = Nimbus.shared.logger
    
    // MARK: - Third Party Demand
    private let thirdPartyInterstitialAdManager = ThirdPartyInterstitialAdManager()
    private var thirdPartyInterstitialAdController: AdController?
    
    init(
        ad: NimbusAd,
        requestManager: NimbusRequestManager,
        clientDelegate: GADFullScreenContentDelegate? = nil,
        rootViewController: UIViewController? = nil
    ) {
        self.ad = ad
        self.requestManager = requestManager
        self.clientDelegate = clientDelegate
        self.rootViewController = rootViewController
        
        super.init()
    }
    
    func updatePrice(_ adValue: GADAdValue) {
        price = adValue.value.multiplying(byPowerOf10: 3).stringValue
    }
    
    func handleEventForNimbus(name: String, info: String?) -> Bool {
        guard name == "na_render", let info = NimbusDynamicPriceRenderInfo(info: info) else {
            return false
        }
        
        renderInfo = info
        notifyWin()
        
        DispatchQueue.main.async { [weak self] in self?.present() }
        
        return true
    }
    
    // MARK: - Notify win/loss
    
    func scheduleLossNotification() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.isNimbusWin {
                self.notifyLoss()
            }
        }
    }
    
    func notifyWin() {
        requestManager.notifyWin(ad: ad, auctionData: NimbusAuctionData())
    }
    
    func notifyLoss() {
        requestManager.notifyLoss(ad: ad, auctionData: NimbusAuctionData(
            auctionPrice: price,
            winningSource: gadInterstitialAd?.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName
        ))
    }
    
    // MARK: - Presentation
    
    /// Make sure this method is called from the main thread
    func present() {
        guard let rootViewController = gadViewController,
              didPresentGoogleController, isNimbusWin, !didPresent
        else {
            return
        }
        
        didPresent = true
        
        if ThirdPartyDemandNetwork.exists(for: ad) {
            do {
                thirdPartyInterstitialAdController = try thirdPartyInterstitialAdManager.render(
                    ad: ad,
                    adPresentingViewController: rootViewController,
                    companionAd: nil
                )
                
                thirdPartyInterstitialAdController?.delegate = self
                thirdPartyInterstitialAdController?.start()
            } catch {
                self.logger.log("NimbusDynamicPriceRenderer: Third-party demand interstitial error: \(error.localizedDescription)", level: .error)
            }
        } else {
            let adView = NimbusAdView(adPresentingViewController: nil)
            
            let adViewController = NimbusAdViewController(
                adView: adView,
                ad: ad,
                companionAd: nil
            )
            adView.delegate = self
            adView.adPresentingViewController = adViewController
            adView.isBlocking = true
            adViewController.delegate = self
            adViewController.modalPresentationStyle = .fullScreen
            adViewController.isDismissAnimated = false
            
            rootViewController.present(adViewController, animated: false)
            adViewController.renderAndStart()
        }
    }
    
    private func dismiss() {
        DispatchQueue.main.async {
            self.gadViewController?.dismiss(animated: false) { [weak self] in
                self?.price = "-1"
                self?.renderInfo = nil
                self?.didPresent = false
                self?.didPresentGoogleController = false
                self?.thirdPartyInterstitialAdController = nil
            }
        }
    }
    
    // MARK: - NimbusEvent Handling
    
    func handleClickEvent() {
        guard let gadInterstitialAd else {
            logger.log("GADInterstitialAd was unexpectedly released before click event could be processed", level: .error)
            return
        }
        guard let renderInfo else {
            logger.log("NimbusDynamicPriceRenderInfo is not present at click event", level: .error)
            return
        }

        adDidRecordClick(gadInterstitialAd)
        
        URLSession.shared.dataTask(with: URLRequest(url: renderInfo.googleClickEventUrl)) { [weak self] _, _, error in
            if let error {
                self?.logger.log(
                    "NimbusDynamicPriceInterstitialAd: Error firing Google click tracker: \(error.localizedDescription)",
                    level: .debug
                )
            } else {
                self?.logger.log(
                    "NimbusDynamicPriceInterstitialAd: Google click tracker fired successfully",
                    level: .info
                )
            }
        }.resume()
    }
}

// MARK: - AdControllerDelegate

extension NimbusDynamicPriceInterstitialAd: AdControllerDelegate {
    func didReceiveNimbusEvent(controller: AdController, event: NimbusEvent) {
        if event == .clicked {
            handleClickEvent()
        } else if event == .destroyed && thirdPartyInterstitialAdController != nil {
            dismiss()
        }
    }
    
    public func didReceiveNimbusError(controller: AdController, error: NimbusCoreKit.NimbusError) {
        if let gadInterstitialAd {
            clientDelegate?.ad?(gadInterstitialAd, didFailToPresentFullScreenContentWithError: error)
            dismiss()
        }
    }
}

// MARK: - GADFullScreenContentDelegate

extension NimbusDynamicPriceInterstitialAd: GADFullScreenContentDelegate {
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        clientDelegate?.ad?(ad, didFailToPresentFullScreenContentWithError: error)
    }
    
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        clientDelegate?.adDidRecordImpression?(ad)
        scheduleLossNotification()
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        clientDelegate?.adDidRecordClick?(ad)
    }
    
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        clientDelegate?.adWillPresentFullScreenContent?(ad)
        
        if !didPresentGoogleController {
            logger.log("Detected GADInterstitialAd.present(fromRootViewController:) was called instead of GADInterstitialAd.presentDynamicPrice(fromRootViewController:)", level: .error)
        }
    }
    
    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        clientDelegate?.adWillDismissFullScreenContent?(ad)
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        clientDelegate?.adDidDismissFullScreenContent?(ad)
    }
}

// MARK: - NimbusAdViewControllerDelegate

extension NimbusDynamicPriceInterstitialAd: NimbusAdViewControllerDelegate {
    public func viewWillAppear(animated: Bool) {}
    public func viewDidAppear(animated: Bool) {}
    public func viewWillDisappear(animated: Bool) {}
    public func viewDidDisappear(animated: Bool) {}
    public func didCloseAd(adView: NimbusAdView) {
        adView.destroy()
        dismiss()
    }
}
