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
    
    func didEarnReward(reward: AdReward)
    func didReceiveError(error: NimbusError)
}

public final class NimbusRewardedAdPresenter {
    
    private enum AdType {
        case rewarded(ad: RewardedAd)
        case rewardedInterstitial(ad: RewardedInterstitialAd)
    }
    
    public weak var delegate: NimbusRewardedAdPresenterDelegate?
    
    private let ad: NimbusAd
    private var adType: AdType?
    private var companionAd: NimbusCompanionAd?
    
    private var adController: AdController?
    
    public init(
        request: NimbusRequest,
        ad: NimbusAd,
        rewardedAd: RewardedAd
    ) {
        self.ad = ad
        self.adType = .rewarded(ad: rewardedAd)
        self.companionAd = getCompanionAd(for: request)
    }
    
    public init(
        request: NimbusRequest,
        ad: NimbusAd,
        rewardedInterstitialAd: RewardedInterstitialAd
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
        do {
            adController = try Nimbus.loadBlocking(
                ad: ad,
                presentingViewController: presentingViewController,
                delegate: self,
                isRewarded: true,
                companionAd: NimbusCompanionAd(width: 320, height: 480, renderMode: .endCard),
                animated: true
            )
            adController?.start()
            
            delegate?.didPresentAd()
        } catch {
            Nimbus.shared.logger.log(
                "NimbusDynamicPriceRenderer: Third-party demand rewarded error: \(error.localizedDescription)",
                level: .error
            )
        }
    }
    
    private func showGoogleAd(presentingViewController: UIViewController) {
        switch adType {
        case let .rewarded(rewardedAd):
            rewardedAd.present(from: presentingViewController) { [weak self] in
                let reward = rewardedAd.adReward
                self?.delegate?.didEarnReward(reward: reward)
            }
        case let .rewardedInterstitial(rewardedInterstitialAd):
            rewardedInterstitialAd.present(from: presentingViewController) { [weak self] in
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
        case .destroyed:
            adController = nil
            adType = nil
            delegate?.didCloseAd()
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
        adController?.destroy()
    }
    
    public func didCloseAd(adView: NimbusAdView) {}
}


/// :nodoc:
private extension Array {
    subscript (safe index: Int) -> Element? {
        index >= 0 && index < self.count ? self[index] : nil
    }
}
