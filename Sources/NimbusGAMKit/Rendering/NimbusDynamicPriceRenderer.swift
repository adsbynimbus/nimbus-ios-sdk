//
//  NimbusDynamicPriceRenderer.swift
//  NimbusGAMKit
//
//  Created by Victor Takai on 04/04/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusKit
@_exported import NimbusRenderKit
import GoogleMobileAds
import UIKit

/// Nimbus Renderer for GAM Dynamic Price
public final class NimbusDynamicPriceRenderer: NSObject, GADAppEventDelegate, NimbusAdViewControllerDelegate, AdControllerDelegate {
        
    struct InterstitialRenderData {
        let renderInfo: NimbusDynamicPriceRenderInfo
        let data: NimbusDynamicPriceCacheManager.GoogleAuctionData
    }
    
    public let requestManager: NimbusRequestManager
    public let logger: Logger
    private let cacheManager = NimbusDynamicPriceCacheManager()
    private var interstitialRenderData: InterstitialRenderData?
    
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
        cacheManager.addData(nimbusAd: ad, fullScreenPresentingAd: fullScreenPresentingAd)
    }
    
    public func willPresent() {
        guard let interstitialRenderData else { return }
        
        DispatchQueue.main.async { [weak self] in
            if let rootViewController = self?.rootViewController,
               let gadViewController = rootViewController.presentedViewController {
                let adView = NimbusAdView(adPresentingViewController: nil)
                let adViewController = NimbusAdViewController(
                    adView: adView,
                    ad: interstitialRenderData.data.nimbusAd,
                    companionAd: nil
                )
                adView.delegate = self
                adView.adPresentingViewController = adViewController
                adViewController.delegate = self
                adViewController.modalPresentationStyle = .fullScreen
                
                gadViewController.present(adViewController, animated: false)
                adViewController.renderAndStart()
                
                self?.cacheManager.addClickEvent(
                    nimbusAdView: adView,
                    clickEventUrl: interstitialRenderData.renderInfo.googleClickEventUrl
                )
            }
            
            self?.cacheManager.updateNimbusDidWin(auctionId: interstitialRenderData.renderInfo.auctionId)
        }
    }
    
    /// Notify price methods
    
    public func notifyBannerPrice(adValue: GADAdValue, bannerView: GADBannerView) {
        let cpmValue = adValue.value.multiplying(byPowerOf10: 3)
        cacheManager.updateBannerPrice(bannerView, price: cpmValue.stringValue)
    }
    
    public func notifyInterstitialPrice(adValue: GADAdValue, fullScreenPresentingAd: GADFullScreenPresentingAd) {
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
            
            self.notifyImpression(
                isNimbusWin: data.isNimbusWin,
                nimbusAd: data.nimbusAd,
                price: data.price,
                responseInfo: bannerView.responseInfo
            )
        }
    }
    
    public func notifyInterstitialImpression(interstitialAd: GADInterstitialAd) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self,
                  let data = self.cacheManager.getData(for: interstitialAd) else {
                return
            }
            
            self.notifyImpression(
                isNimbusWin: data.isNimbusWin,
                nimbusAd: data.nimbusAd,
                price: data.price,
                responseInfo: interstitialAd.responseInfo
            )
        }
    }
    
    public func notifyInterstitialImpression(rewardedInterstitialAd: GADRewardedInterstitialAd) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self,
                  let data = self.cacheManager.getData(for: rewardedInterstitialAd) else {
                return
            }
            
            self.notifyImpression(
                isNimbusWin: data.isNimbusWin,
                nimbusAd: data.nimbusAd,
                price: data.price,
                responseInfo: rewardedInterstitialAd.responseInfo
            )
        }
    }
    
    private func notifyImpression(isNimbusWin: Bool, nimbusAd: NimbusAd, price: String, responseInfo: GADResponseInfo?) {
        if isNimbusWin {
            requestManager.notifyWin(ad: nimbusAd, auctionData: NimbusAuctionData())
        } else {
            requestManager.notifyLoss(ad: nimbusAd, auctionData: NimbusAuctionData(
                auctionPrice: price,
                winningSource: responseInfo?.adNetworkClassName
            ))
        }
        cacheManager.removeData(auctionId: nimbusAd.auctionId)
    }
    
    /// Handle event methods
    
    public func handleBannerEventForNimbus(bannerView: GADBannerView, name: String, info: String?) {
        guard name == "na_render",
              let renderInfo = getRenderInfo(info: info),
              let data = cacheManager.getData(for: renderInfo.auctionId) else {
            return
        }
        
        let adView = NimbusAdView(adPresentingViewController: rootViewController)
        adView.delegate = self
        bannerView.addSubview(adView)
        
        adView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adView.safeAreaLayoutGuide.topAnchor.constraint(
                equalTo: bannerView.safeAreaLayoutGuide.topAnchor
            ),
            adView.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: bannerView.safeAreaLayoutGuide.bottomAnchor
            ),
            adView.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: bannerView.safeAreaLayoutGuide.leadingAnchor
            ),
            adView.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: bannerView.safeAreaLayoutGuide.trailingAnchor
            )
        ])
        
        adView.render(ad: data.nimbusAd)
        adView.start()
        
        cacheManager.addClickEvent(
            nimbusAdView: adView,
            clickEventUrl: renderInfo.googleClickEventUrl
        )
        cacheManager.updateNimbusDidWin(auctionId: renderInfo.auctionId)
    }
    
    public func handleInterstitialEventForNimbus(name: String, info: String?) {
        guard name == "na_render",
              let renderInfo = getRenderInfo(info: info),
              let data = cacheManager.getData(for: renderInfo.auctionId) else {
            return
        }
        
        self.interstitialRenderData = .init(renderInfo: renderInfo, data: data)
    }
    
    /// AdControllerDelegate methdos
   
    public func didReceiveNimbusEvent(controller: AdController, event: NimbusEvent) {
        guard let adView = controller as? NimbusAdView,
              let url = cacheManager.getClickEvent(nimbusAdView: adView) else {
            return
        }
        
        if event == .clicked {
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
        }
    }
    
    public func didReceiveNimbusError(controller: AdController, error: NimbusCoreKit.NimbusError) {}
    
    /// NimbusAdViewControllerDelegate methods
    
    public func viewWillAppear(animated: Bool) {}
    
    public func viewDidAppear(animated: Bool) {}
    
    public func viewWillDisappear(animated: Bool) {}
    
    public func viewDidDisappear(animated: Bool) {}
    
    public func didCloseAd(adView: NimbusAdView) {
        DispatchQueue.main.async { [weak self] in
            guard let self,
                  let rootViewController = self.rootViewController,
                  let gadViewController = rootViewController.presentedViewController else {
                return
            }
            
            gadViewController.dismiss(animated: false)
        }
    }
    
    /// Utils
    
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
    
    func getRenderInfo(info: String?) -> NimbusDynamicPriceRenderInfo? {
        guard let data = info?.data(using: .utf8) else {
            logger.log(
                "NimbusDynamicPriceRenderer: Unable to encode render info string",
                level: .error
            )
            return nil
        }
        
        do {
            return try JSONDecoder().decode(NimbusDynamicPriceRenderInfo.self, from: data)
        } catch {
            logger.log(error.localizedDescription, level: .error)
            return nil
        }
    }
}
