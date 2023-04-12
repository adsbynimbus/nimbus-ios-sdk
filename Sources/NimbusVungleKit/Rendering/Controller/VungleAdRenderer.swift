//
//  VungleAdRenderer.swift
//  NimbusVungleKit
//
//  Created by Inder Dhir on 2/16/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import UIKit
import VungleSDK

final class VungleAdRenderer {
    
    private let vungleProxyType: NimbusVungleProxyType
    private(set) var hasRenderedAd = false
    
    init(vungleProxyType: NimbusVungleProxyType) {
        self.vungleProxyType = vungleProxyType
    }
    
    func startAd(
        ad: NimbusAd,
        adType: NimbusVungleAdLoader.AdType,
        container: UIView?,
        volume: Int,
        adPresentingViewController: UIViewController?
    ) throws {
        guard !hasRenderedAd else { return }
        
        let options = [VunglePlayAdOptionKeyStartMuted: volume == 0 ? 1 : 0]
        switch adType {
        case .mrecOrBanner:
            guard let container else {
                throw NimbusVungleError.failedToStartStaticAd(
                    type: "mrec",
                    message: "Container view not found."
                )
            }
            try startMrecOrBannerAd(ad: ad, container: container, options: options)
        case .interstitial:
            try startInterstitialAd(ad: ad, options: options, adPresentingViewController: adPresentingViewController)
        }
    }
    
    func destroy(ad: NimbusAd) {
        if hasRenderedAd, let placementId = ad.placementId {
            vungleProxyType.finishDisplayingAd(
                id: placementId,
                markup: ad.markup
            )
        }
    }
    
    private func startMrecOrBannerAd(ad: NimbusAd, container: UIView, options: [String: Int]) throws {
        let viewSize = ad.isAdMRECType ?
        CGSize(width: 300, height: 250) :
        CGSize(
            width: ad.adDimensions?.width ?? Int(container.frame.width),
            height: ad.adDimensions?.height ?? Int(container.frame.height)
        )
        
        let adContainerView = UIView()
        container.addSubview(adContainerView)

        adContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adContainerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            adContainerView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            adContainerView.widthAnchor.constraint(equalToConstant: viewSize.width),
            adContainerView.heightAnchor.constraint(equalToConstant: viewSize.height)
        ])
        adContainerView.layoutIfNeeded()
        
        do {
            try vungleProxyType.addAdView(to: adContainerView, options: options, id: ad.placementId, markup: ad.markup)
            hasRenderedAd = true
        } catch {
            throw NimbusRenderError.adRenderingFailed(message: error.localizedDescription)
        }
    }
    
    private func startInterstitialAd(
        ad: NimbusAd,
        options: [String: Int],
        adPresentingViewController: UIViewController?
    ) throws {
        guard let adPresentingViewController else {
            throw NimbusVungleError.failedToStartStaticAd(
                type: "interstitial",
                message: "Presenting view controller not found."
            )
        }
        
        do {
            try vungleProxyType.playAd(adPresentingViewController, options: options, id: ad.placementId, markup: ad.markup)
            hasRenderedAd = true
        } catch {
            throw NimbusRenderError.adRenderingFailed(message: error.localizedDescription)
        }
    }
}
