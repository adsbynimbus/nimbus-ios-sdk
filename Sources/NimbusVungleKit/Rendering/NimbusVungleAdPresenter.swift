//
//  NimbusVungleAdPresenter.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 18/05/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import VungleAdsSDK
import UIKit

protocol NimbusVungleAdPresenterType {
    func present(bannerAd: VungleBanner?, ad: NimbusAd, container: NimbusAdView?) throws
    func present(interstitialAd: VungleInterstitial?, adPresentingViewController: UIViewController?) throws
    func present(rewardedAd: VungleRewarded?, adPresentingViewController: UIViewController?) throws
}

final class NimbusVungleAdPresenter: NimbusVungleAdPresenterType {
        
    func present(bannerAd: VungleBanner?, ad: NimbusAd, container: NimbusAdView?) throws {
        guard let adDimensions = ad.adDimensions else {
            throw NimbusVungleError.failedToPresentAd(
                type: "banner",
                message: "Ad dimensions is not set."
            )
        }
        
        guard let container else {
            throw NimbusVungleError.failedToPresentAd(
                type: "banner",
                message: "Container view not found."
            )
        }
            
        guard let bannerAd else {
            throw NimbusVungleError.failedToPresentAd(
                type: "banner",
                message: "Vungle Ad not found."
            )
        }
        
        guard bannerAd.canPlayAd() else {
            throw NimbusVungleError.failedToPresentAd(
                type: "banner",
                message: "Vungle Ad cannot be played."
            )
        }
        
        let adContainerView = UIView()
        container.addSubview(adContainerView)

        setupVungleBannerConstraints(container: container, adContainerView: adContainerView, adDimensions: adDimensions)
 
        bannerAd.present(on: adContainerView)
    }
    
    func present(interstitialAd: VungleInterstitial?, adPresentingViewController: UIViewController?) throws {
        guard let adPresentingViewController else {
            throw NimbusVungleError.failedToPresentAd(
                type: "interstitial",
                message: "Presenting view controller not found."
            )
        }
        
        guard let interstitialAd else {
            throw NimbusVungleError.failedToPresentAd(
                type: "interstitial",
                message: "Vungle Ad not found."
            )
        }
        
        guard interstitialAd.canPlayAd() else {
            throw NimbusVungleError.failedToPresentAd(
                type: "interstitial",
                message: "Vungle Ad cannot be played."
            )
        }
        
        interstitialAd.present(with: adPresentingViewController)
    }
    
    func present(rewardedAd: VungleRewarded?, adPresentingViewController: UIViewController?) throws {
        guard let adPresentingViewController else {
            throw NimbusVungleError.failedToPresentAd(
                type: "rewarded",
                message: "Presenting view controller not found."
            )
        }
        
        guard let rewardedAd else {
            throw NimbusVungleError.failedToPresentAd(
                type: "rewarded",
                message: "Vungle Ad not found."
            )
        }
        
        guard rewardedAd.canPlayAd() else {
            throw NimbusVungleError.failedToPresentAd(
                type: "rewarded",
                message: "Vungle Ad cannot be played."
            )
        }
        
        rewardedAd.present(with: adPresentingViewController)
    }
    
    private func setupVungleBannerConstraints(container: UIView, adContainerView: UIView, adDimensions: NimbusAdDimensions) {
        adContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let maxWidth = adContainerView.widthAnchor.constraint(lessThanOrEqualTo: container.widthAnchor)
        let maxHeight = adContainerView.heightAnchor.constraint(lessThanOrEqualTo: container.heightAnchor)
        let preferredWidthConstraint = adContainerView.widthAnchor.constraint(equalToConstant: CGFloat(adDimensions.width))
        preferredWidthConstraint.priority = .defaultHigh
        let preferredHeightConstraint = adContainerView.heightAnchor.constraint(equalToConstant: CGFloat(adDimensions.height))
        preferredHeightConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            adContainerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            adContainerView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            maxWidth, maxHeight,
            preferredWidthConstraint, preferredHeightConstraint
        ])
        
        // Vungle seems to be doing an internal frame check where the ad does NOT render if the frame is zero
        adContainerView.frame = .init(origin: .zero, size: CGSize(width: adDimensions.width, height: adDimensions.height))
    }
}
