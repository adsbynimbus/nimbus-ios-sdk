//
//  NimbusDynamicPriceRewardedWrapper.swift
//  Nimbus
//
//  Created on 7/23/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusKit
import GoogleMobileAds

public protocol NimbusRewardedAdPresenterDelegate: AnyObject {
    func didTriggerImpression()
    func didTriggerClick()
    
    func didPresentAd()
    func didCloseAd()
    
    func didEarnReward(reward: GADAdReward)
    func didReceiveError(error: NimbusError)
}

public final class NimbusRewardedAdPresenter {
    
    private enum AdType {
        case rewarded(ad: GADRewardedAd)
        case rewardedInterstitial(ad: GADRewardedInterstitialAd)
    }
    
    public weak var delegate: NimbusRewardedAdPresenterDelegate?
    
    private let ad: NimbusAd
    private var adType: AdType?
    private var companionAd: NimbusCompanionAd?
    private var adView: NimbusAdView?
    
    private let thirdPartyInterstitialAdManager = ThirdPartyInterstitialAdManager()
    private var thirdPartyAdController: AdController?
    
    public init(
        request: NimbusRequest,
        ad: NimbusAd,
        rewardedAd: GADRewardedAd
    ) {
        self.ad = ad
        self.adType = .rewarded(ad: rewardedAd)
        self.companionAd = getCompanionAd(for: request)
    }
    
    public init(
        request: NimbusRequest,
        ad: NimbusAd,
        rewardedInterstitialAd: GADRewardedInterstitialAd
    ) {
        self.ad = ad
        self.adType = .rewardedInterstitial(ad: rewardedInterstitialAd)
        self.companionAd = getCompanionAd(for: request)
    }
    
    public func showAd(isNimbusWin: Bool, presentingViewController: UIViewController) {
        if isNimbusWin {
            showNimbusAd(presentingViewController: presentingViewController)
        } else {
            showGoogleAd(presentingViewController: presentingViewController)
        }
    }
    
    private func showNimbusAd(presentingViewController: UIViewController) {
        if ThirdPartyDemandNetwork.exists(for: ad) {
            do {
                thirdPartyAdController = try thirdPartyInterstitialAdManager.render(
                    ad: ad,
                    adPresentingViewController: presentingViewController,
                    companionAd: nil
                )
                
                thirdPartyAdController?.delegate = self
                thirdPartyAdController?.start()
                
                delegate?.didPresentAd()
            } catch {
                Nimbus.shared.logger.log("NimbusDynamicPriceRenderer: Third-party demand rewarded error: \(error.localizedDescription)", level: .error)
            }
        } else {
            adView = NimbusAdView(adPresentingViewController: nil)
            guard let adView else { return }
            
            let adViewController = NimbusAdViewController(
                adView: adView,
                ad: ad,
                companionAd: companionAd,
                closeButtonDelay: 5,
                isRewardedAd: true
            )
            adView.delegate = self
            adView.adPresentingViewController = adViewController
            adView.isBlocking = true
            
            adViewController.delegate = self
            adViewController.modalPresentationStyle = .fullScreen
            
            presentingViewController.present(adViewController, animated: true, completion: nil)
            adViewController.renderAndStart()
        }
    }
    
    private func showGoogleAd(presentingViewController: UIViewController) {
        switch adType {
        case let .rewarded(rewardedAd):
            rewardedAd.present(fromRootViewController: presentingViewController) { [weak self] in
                let reward = rewardedAd.adReward
                self?.delegate?.didEarnReward(reward: reward)
            }
        case let .rewardedInterstitial(rewardedInterstitialAd):
            rewardedInterstitialAd.present(fromRootViewController: presentingViewController) { [weak self] in
                let reward = rewardedInterstitialAd.adReward
                self?.delegate?.didEarnReward(reward: reward)
            }
        default:
            break
        }
    }
    
    private func getCompanionAd(for request: NimbusRequest) -> NimbusCompanionAd? {
        if let firstCompanionAd = request.impressions[safe: 0]?.video?.companionAds?.first {
            return NimbusCompanionAd(
                width: firstCompanionAd.width,
                height: firstCompanionAd.height,
                renderMode: firstCompanionAd.companionAdRenderMode ?? .concurrent
            )
        }
        return nil
    }
}

// MARK: AdControllerDelegate

/// :nodoc:
extension NimbusRewardedAdPresenter: AdControllerDelegate {
    public func didReceiveNimbusEvent(controller: NimbusCoreKit.AdController, event: NimbusCoreKit.NimbusEvent) {
        switch event {
        case .impression:
            delegate?.didTriggerImpression()
        case .clicked:
            delegate?.didTriggerClick()
        case .completed:
            switch adType {
            case let .rewarded(ad):
                delegate?.didEarnReward(reward: ad.adReward)
            case let .rewardedInterstitial(ad):
                delegate?.didEarnReward(reward: ad.adReward)
            default:
                break
            }
        case .destroyed where thirdPartyAdController != nil:
            delegate?.didCloseAd()
            thirdPartyAdController = nil
        default:
            break
        }
    }
    
    public func didReceiveNimbusError(controller: NimbusCoreKit.AdController, error: NimbusCoreKit.NimbusError) {
        delegate?.didReceiveError(error: error)
    }
}

// MARK: NimbusAdViewControllerDelegate

/// :nodoc:
extension NimbusRewardedAdPresenter: NimbusAdViewControllerDelegate {
    public func viewWillAppear(animated: Bool) {}
    
    public func viewDidAppear(animated: Bool) {
        delegate?.didPresentAd()
    }
    
    public func viewWillDisappear(animated: Bool) {}
    
    public func viewDidDisappear(animated: Bool) {
        adView?.destroy()
        adType = nil
        
        delegate?.didCloseAd()
    }
    
    public func didCloseAd(adView: NimbusAdView) {}
}

/// :nodoc:
private extension Array {
    subscript (safe index: Int) -> Element? {
        index >= 0 && index < self.count ? self[index] : nil
    }
}
