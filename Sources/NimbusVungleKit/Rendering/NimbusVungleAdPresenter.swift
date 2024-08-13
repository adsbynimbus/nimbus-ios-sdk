//
//  NimbusVungleAdPresenter.swift
//  NimbusVungleKit
//
//  Created on 18/05/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit
import VungleAdsSDK
import UIKit

protocol NimbusVungleAdPresenterType {
    func present(bannerAd: VungleBannerView?, ad: NimbusAd, container: NimbusAdView?, creativeScalingEnabled: Bool) throws
    func present(interstitialAd: VungleInterstitial?, adPresentingViewController: UIViewController?) throws
    func present(rewardedAd: VungleRewarded?, adPresentingViewController: UIViewController?) throws
    func present(
        nativeAd: VungleNative?,
        ad: NimbusAd,
        container: NimbusAdView?,
        viewController: UIViewController?,
        adRendererDelegate: NimbusVungleAdRendererDelegate?
    ) throws
}

final class NimbusVungleAdPresenter: NimbusVungleAdPresenterType {
    
    func present(
        bannerAd: VungleBannerView?,
        ad: NimbusAd,
        container: NimbusAdView?,
        creativeScalingEnabled: Bool
    ) throws {
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
        
        container.addSubview(bannerAd)
        
        if creativeScalingEnabled {
            NimbusCreativeScaler().scaleCreativeIfNecessary(ad: ad, view: bannerAd)
        }
        
        setupVungleBannerConstraints(container: container, adContainerView: bannerAd, adDimensions: adDimensions)
    }
    
    func present(
        nativeAd: VungleNative?,
        ad: NimbusAd,
        container: NimbusAdView?,
        viewController: UIViewController?,
        adRendererDelegate: NimbusVungleAdRendererDelegate?
    ) throws {
        guard let container else {
            throw NimbusVungleError.failedToPresentAd(
                type: "native",
                message: "Container view not found."
            )
        }

        guard let nativeAd else {
            throw NimbusVungleError.failedToPresentAd(
                type: "native",
                message: "Vungle Ad not found."
            )
        }
        
        guard let viewController else {
            throw NimbusVungleError.failedToPresentAd(
                type: "native",
                message: "Vungle ad presenting controller not found."
            )
        }
        
        guard let adRendererDelegate else {
            throw NimbusVungleError.failedToPresentAd(
                type: "native",
                message: "Error retrieving native ad view. Please implement NimbusVungleAdRenderer.adRendererDelegate"
            )
        }
        
        let adView = adRendererDelegate.customViewForRendering(container: container, nativeAd: nativeAd)
        
        adView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(adView)
        NSLayoutConstraint.activate([
            adView.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
            adView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
            adView.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        nativeAd.registerViewForInteraction(
            view: adView,
            mediaView: adView.mediaView,
            iconImageView: adView.iconImageView,
            viewController: viewController,
            clickableViews: adView.clickableViews
        )
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
