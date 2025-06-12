//
//  NimbusDynamicPriceInterstitialAd.swift
//  NimbusGAMKit
//  Created on 2/16/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UIKit
import GoogleMobileAds
import NimbusKit

final class NimbusDynamicPriceInterstitialAd: NSObject {
    weak var rootViewController: UIViewController?
    var didPresentGoogleController = false
    
    /// This is the publisher's original delegate. If set, we forward events to it.
    private weak var clientDelegate: FullScreenContentDelegate?
    private weak var gadInterstitialAd: InterstitialAd?
    
    private var gadViewController: UIViewController? { rootViewController?.presentedViewController }
    
    private var didPresent = false
    private let requestManager: NimbusRequestManager
    private let ad: NimbusAd
    private var isNimbusWin: Bool { renderInfo != nil }
    private var price = "-1"
    
    private var renderInfo: NimbusDynamicPriceRenderInfo?
    private let logger = Nimbus.shared.logger
    
    private var adController: AdController?
    
    init(
        ad: NimbusAd,
        requestManager: NimbusRequestManager,
        clientDelegate: FullScreenContentDelegate? = nil,
        rootViewController: UIViewController? = nil,
        gadInterstitialAd: InterstitialAd? = nil
    ) {
        self.ad = ad
        self.requestManager = requestManager
        self.clientDelegate = clientDelegate
        self.rootViewController = rootViewController
        self.gadInterstitialAd = gadInterstitialAd
        
        super.init()
    }
    
    func updatePrice(_ adValue: AdValue) {
        price = adValue.nimbusPrice
    }
    
    @discardableResult
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
    
    private func scheduleLossNotification() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.isNimbusWin {
                self.notifyLoss()
            }
        }
    }
    
    private func notifyWin() {
        requestManager.notifyWin(ad: ad, auctionData: NimbusAuctionData())
    }
    
    private func notifyLoss() {
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
        
        do {
            adController = try Nimbus.loadBlocking(
                ad: ad,
                presentingViewController: rootViewController,
                delegate: self,
                isRewarded: false,
                companionAd: NimbusCompanionAd(width: 320, height: 480, renderMode: .endCard),
                animated: false
            )
            adController?.start()
        } catch {
            self.logger.log(
                "NimbusDynamicPriceRenderer: interstitial error: \(error.localizedDescription)",
                level: .error
            )
        }
    }
     
    private func dismiss() {
        DispatchQueue.main.async {
            self.price = "-1"
            self.renderInfo = nil
            self.didPresent = false
            self.didPresentGoogleController = false
            self.adController = nil
            self.gadViewController?.dismiss(animated: false)
        }
    }
    
    // MARK: - NimbusEvent Handling
    
    private func handleClickEvent() {
        guard let gadInterstitialAd else {
            logger.log("GADInterstitialAd was unexpectedly released before click event could be processed", level: .error)
            return
        }
        guard let renderInfo else {
            logger.log("NimbusDynamicPriceRenderInfo is not present at click event", level: .error)
            return
        }

        adDidRecordClick(gadInterstitialAd)
        
        URLSession.trackClick(url: renderInfo.googleClickEventUrl, logger: logger)
    }
}

// MARK: - AdControllerDelegate

extension NimbusDynamicPriceInterstitialAd: AdControllerDelegate {
    func didReceiveNimbusEvent(controller: AdController, event: NimbusEvent) {        
        if event == .clicked {
            handleClickEvent()
        } else if event == .destroyed {
            dismiss()
        }
    }
    
    func didReceiveNimbusError(controller: AdController, error: NimbusCoreKit.NimbusError) {
        if let gadInterstitialAd {
            clientDelegate?.ad?(gadInterstitialAd, didFailToPresentFullScreenContentWithError: error)
            dismiss()
        }
    }
}

// MARK: - GADFullScreenContentDelegate

extension NimbusDynamicPriceInterstitialAd: FullScreenContentDelegate {
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        clientDelegate?.ad?(ad, didFailToPresentFullScreenContentWithError: error)
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        clientDelegate?.adDidRecordImpression?(ad)
        scheduleLossNotification()
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        clientDelegate?.adDidRecordClick?(ad)
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        clientDelegate?.adWillPresentFullScreenContent?(ad)
        
        if !didPresentGoogleController {
            logger.log("Detected GADInterstitialAd.present(fromRootViewController:) was called instead of GADInterstitialAd.presentDynamicPrice(fromRootViewController:)", level: .error)
        }
    }
    
    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        clientDelegate?.adWillDismissFullScreenContent?(ad)
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        clientDelegate?.adDidDismissFullScreenContent?(ad)
    }
}

// MARK: - NimbusAdViewControllerDelegate

extension NimbusDynamicPriceInterstitialAd: NimbusAdViewControllerDelegate {
    func viewWillAppear(animated: Bool) {}
    func viewDidAppear(animated: Bool) {}
    func viewWillDisappear(animated: Bool) {}
    func viewDidDisappear(animated: Bool) {}
    func didCloseAd(adView: NimbusAdView) {
        adController?.destroy()
    }
}
