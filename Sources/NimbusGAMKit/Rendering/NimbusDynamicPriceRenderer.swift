//
//  NimbusDynamicPriceRenderer.swift
//  NimbusGAMKit
//
//  Created on 04/04/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusKit
@_exported import NimbusRenderKit
import GoogleMobileAds
import UIKit

/// Nimbus Renderer for GAM Dynamic Price
@available(*, deprecated, message: "Please check out the Nimbus documentation to implement dynamic price.")
public final class NimbusDynamicPriceRenderer: NSObject, GADAppEventDelegate {
    
    struct InterstitialRenderData {
        let renderInfo: NimbusDynamicPriceRenderInfo
        let data: NimbusDynamicPriceCacheManager.GoogleAuctionData
    }
    
    public let requestManager: NimbusRequestManager
    public let logger: Logger
    
    private let cacheManager = NimbusDynamicPriceCacheManager()
    private var interstitialRenderData: InterstitialRenderData?
    private weak var interstitialAd: GADFullScreenPresentingAd?
    private var adController: AdController?
    private weak var adView: UIView? // used for caching
    
    public init(
        requestManager: NimbusRequestManager = NimbusRequestManager(),
        logger: Logger = Nimbus.shared.logger
    ) {
        self.requestManager = requestManager
        self.logger = logger
    }
    
    /// Will render methods
    
    public func willRender(ad: NimbusAd, bannerView: GADBannerView) {
        cacheManager.addData(nimbusAd: ad, bannerView: bannerView)
    }
    
    public func willRender(ad: NimbusAd, fullScreenPresentingAd: GADFullScreenPresentingAd) {
        interstitialAd = fullScreenPresentingAd
        cacheManager.addData(nimbusAd: ad, fullScreenPresentingAd: fullScreenPresentingAd)
    }
    
    public func willPresent() {
        guard let interstitialRenderData else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard let rootViewController = self.rootViewController,
                  let gadViewController = rootViewController.presentedViewController else {
                self.logger.log("NimbusDynamicPriceRenderer: Could not find GADViewController", level: .error)
                return
            }
            
            let ad = interstitialRenderData.data.nimbusAd
            
            do {
                adController = try Nimbus.loadBlocking(
                    ad: ad,
                    presentingViewController: gadViewController,
                    delegate: self,
                    isRewarded: false,
                    companionAd: NimbusCompanionAd(width: 320, height: 480, renderMode: .endCard),
                    animated: false
                )
                adController?.start()
                
                self.adView = gadViewController.view
                
                cacheManager.addClickEvent(
                    nimbusAdView: gadViewController.view,
                    clickEventUrl: interstitialRenderData.renderInfo.googleClickEventUrl
                )
            } catch {
                self.logger.log("NimbusDynamicPriceRenderer: Could not render a blocking ad: \(error)", level: .error)
            }
        }
    }
    
    /// Notify price methods
    
    public func notifyBannerPrice(adValue: GADAdValue, bannerView: GADBannerView) {
        let cpmValue = adValue.value.multiplying(byPowerOf10: 3)
        cacheManager.updateBannerPrice(bannerView, price: cpmValue.stringValue)
    }
    
    public func notifyInterstitialPrice(adValue: GADAdValue, fullScreenPresentingAd: GADFullScreenPresentingAd) {
        notifyFullScreenAdPrice(adValue: adValue, fullScreenPresentingAd: fullScreenPresentingAd)
    }
    
    public func notifyRewardedPrice(adValue: GADAdValue, fullScreenPresentingAd: GADFullScreenPresentingAd) {
        notifyFullScreenAdPrice(adValue: adValue, fullScreenPresentingAd: fullScreenPresentingAd)
    }
    
    public func notifyRewardedInterstitialPrice(adValue: GADAdValue, fullScreenPresentingAd: GADFullScreenPresentingAd) {
        notifyFullScreenAdPrice(adValue: adValue, fullScreenPresentingAd: fullScreenPresentingAd)
    }
    
    private func notifyFullScreenAdPrice(adValue: GADAdValue, fullScreenPresentingAd: GADFullScreenPresentingAd) {
        let cpmValue = adValue.value.multiplying(byPowerOf10: 3)
        cacheManager.updateInterstitialPrice(fullScreenPresentingAd, price: cpmValue.stringValue)
    }
    
    /// Notify loss methods
    
    public func notifyBannerLoss(bannerView: GADBannerView, error: Error) {
        guard let errorCode = GADErrorCode(rawValue: (error as NSError).code) else {
            logger.log("NimbusDynamicPriceRenderer: GADErrorCode not found", level: .error)
            return
        }
        
        guard errorCode == .noFill || errorCode == .mediationNoFill else {
            return
        }
        
        if let data = cacheManager.getData(for: bannerView) {
            notifyLoss(nimbusAd: data.nimbusAd)
        }
    }
    
    public func notifyInterstitialLoss(fullScreenPresentingAd: GADFullScreenPresentingAd, error: Error) {
        guard let errorCode = GADErrorCode(rawValue: (error as NSError).code),
              errorCode == .noFill || errorCode == .mediationNoFill else {
            logger.log("NimbusDynamicPriceRenderer: GADErrorCode not found", level: .error)
            return
        }
        
        if let data = cacheManager.getData(for: fullScreenPresentingAd) {
            notifyLoss(nimbusAd: data.nimbusAd)
        }
    }
    
    private func notifyLoss(nimbusAd: NimbusAd) {
        requestManager.notifyLoss(
            ad: nimbusAd,
            auctionData: NimbusAuctionData(auctionPrice: "-1")
        )
        cacheManager.removeData(auctionId: nimbusAd.auctionId)
    }
    
    /// Notify impression methods
    
    public func notifyBannerImpression(bannerView: GADBannerView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self,
                  let data = self.cacheManager.getData(for: bannerView) else {
                return
            }
            
            self.notifyWinLoss(
                isNimbusWin: data.isNimbusWin,
                nimbusAd: data.nimbusAd,
                price: data.price,
                responseInfo: bannerView.responseInfo
            )
        }
    }
    
    public func notifyInterstitialImpression(interstitialAd: GADInterstitialAd) {
        notifyWinLoss(
            ad: interstitialAd,
            responseInfo: interstitialAd.responseInfo
        )
    }
    
    private func updateNimbusWin(ad: GADFullScreenPresentingAd, isNimbusWin: Bool) {
        if isNimbusWin, let data = self.cacheManager.getData(for: ad) {
            cacheManager.updateNimbusDidWin(auctionId: data.nimbusAd.auctionId)
        }
    }
    
    private func notifyWinLoss(ad: GADFullScreenPresentingAd, responseInfo: GADResponseInfo) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self,
                  let data = self.cacheManager.getData(for: ad) else {
                return
            }
            
            self.notifyWinLoss(
                isNimbusWin: data.isNimbusWin,
                nimbusAd: data.nimbusAd,
                price: data.price,
                responseInfo: responseInfo
            )
        }
    }
    
    private func notifyWinLoss(isNimbusWin: Bool, nimbusAd: NimbusAd, price: String, responseInfo: GADResponseInfo?) {
        if isNimbusWin {
            requestManager.notifyWin(ad: nimbusAd, auctionData: NimbusAuctionData())
        } else {
            requestManager.notifyLoss(ad: nimbusAd, auctionData: NimbusAuctionData(
                auctionPrice: price,
                winningSource: responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName
            ))
        }
        cacheManager.removeData(auctionId: nimbusAd.auctionId)
    }
    
    /// Handle event methods
    
    @discardableResult
    public func handleBannerEventForNimbus(bannerView: GADBannerView, name: String, info: String?) -> Bool {
        guard name == "na_render",
              let renderInfo = NimbusDynamicPriceRenderInfo(info: info),
              let data = cacheManager.getData(for: renderInfo.auctionId) else {
            return false
        }
        
        guard let rootViewController = bannerView.rootViewController else {
            logger.log("GADBannerView.rootViewController must be set, see https://developers.google.com/ad-manager/mobile-ads-sdk/ios/banner#configure_properties", level: .error)
            return false
        }
        
        let adController = Nimbus.load(
            ad: data.nimbusAd,
            container: bannerView,
            adPresentingViewController: rootViewController,
            delegate: self,
            companionAd: NimbusCompanionAd(width: 320, height: 480, renderMode: .endCard)
        )
        guard let adView = adController.adView else {
            logger.log("\(#file) adController.adView returned nil", level: .error)
            return false
        }
        
        self.adView = adView
        
        cacheManager.addClickEvent(
            nimbusAdView: adView,
            clickEventUrl: renderInfo.googleClickEventUrl
        )
        cacheManager.updateNimbusDidWin(auctionId: renderInfo.auctionId)
        
        return true
    }
    
    @discardableResult
    public func handleInterstitialEventForNimbus(name: String, info: String?) -> Bool {
        guard name == "na_render",
              let renderInfo = NimbusDynamicPriceRenderInfo(info: info),
              let data = cacheManager.getData(for: renderInfo.auctionId) else {
            return false
        }
        
        self.cacheManager.updateNimbusDidWin(auctionId: renderInfo.auctionId)
        self.interstitialRenderData = .init(renderInfo: renderInfo, data: data)
        
        return true
    }
    
    public func handleRewardedEventForNimbus(
        adMetadata: [GADAdMetadataKey : Any]?,
        ad: GADRewardedAd
    ) -> Bool {
        let adSystem = adMetadata?[GADAdMetadataKey(rawValue: "AdSystem")] as? String
        let isNimbusWin = adSystem?.contains("Nimbus") ?? false
        
        updateNimbusWin(ad: ad, isNimbusWin: isNimbusWin)
        notifyWinLoss(ad: ad, responseInfo: ad.responseInfo)
        
        return isNimbusWin
    }
    
    public func handleRewardedInterstitialEventForNimbus(
        adMetadata: [GADAdMetadataKey : Any]?,
        ad: GADRewardedInterstitialAd
    ) -> Bool {
        let adSystem = adMetadata?[GADAdMetadataKey(rawValue: "AdSystem")] as? String
        let isNimbusWin = adSystem?.contains("Nimbus") ?? false
        
        updateNimbusWin(ad: ad, isNimbusWin: isNimbusWin)
        notifyWinLoss(ad: ad, responseInfo: ad.responseInfo)

        return isNimbusWin
    }
    
    private var rootViewController: UIViewController? {
        var rootViewController: UIViewController?
        
        if #available(iOS 15.0, *) {
            let allScenes = UIApplication.shared.connectedScenes
            let scene = allScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
            rootViewController = scene?.keyWindow?.rootViewController
        } else {
            let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            rootViewController = (keyWindow ?? UIApplication.shared.windows.first)?.rootViewController
        }
        
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.topViewController
        } else {
            return rootViewController
        }
    }
    
    private func dismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let rootViewController = self.rootViewController,
                  let gadViewController = rootViewController.presentedViewController else {
                return
            }
            
            gadViewController.dismiss(animated: false)
        }
    }
}

extension NimbusDynamicPriceRenderer: AdControllerDelegate {
    public func didReceiveNimbusEvent(controller: AdController, event: NimbusEvent) {
        guard let adView else {
            logger.log("NimbusDynamicPriceRenderer: Couldn't locate adView", level: .error)
            return
        }
        
        guard let url = cacheManager.getClickEvent(nimbusAdView: adView) else {
            logger.log("NimbusDynamicPriceRenderer: couldn't find cache for adView: \(adView)", level: .error)
            return
        }
        
        if event == .clicked {
            // TODO: Make a cleaner solution in a major release
            if let bannerView = adView.superview as? GAMBannerView {
                bannerView.delegate?.bannerViewDidRecordClick?(bannerView)
            } else if let interstitialAd {
                interstitialAd.fullScreenContentDelegate?.adDidRecordClick?(interstitialAd)
            }
            
            URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] _, _, error in
                if let error {
                    self?.logger.log(
                        "NimbusDynamicPriceRenderer: Error firing Google click tracker: \(error.localizedDescription)",
                        level: .error
                    )
                } else {
                    self?.logger.log(
                        "NimbusDynamicPriceRenderer: Google click tracker fired successfully",
                        level: .debug
                    )
                }
            }.resume()
        } else if event == .destroyed {
            cacheManager.removeClickEvent(nimbusAdView: adView)
            interstitialAd = nil
            interstitialRenderData = nil
            
            if adController != nil {
                adController = nil
                dismiss()
            }
        }
    }
    
    public func didReceiveNimbusError(controller: AdController, error: NimbusCoreKit.NimbusError) {}
}

extension NimbusDynamicPriceRenderer: NimbusAdViewControllerDelegate {
    public func viewWillAppear(animated: Bool) {}
    public func viewDidAppear(animated: Bool) {}
    public func viewWillDisappear(animated: Bool) {}
    public func viewDidDisappear(animated: Bool) {}
    public func didCloseAd(adView: NimbusAdView) {
        adController?.destroy()
    }
}
