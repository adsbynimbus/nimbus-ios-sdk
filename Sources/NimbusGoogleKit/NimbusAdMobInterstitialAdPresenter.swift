//
//  NimbusAdMobInterstitialAdPresenter.swift
//  Nimbus
//
//  Created by Inder Dhir on 7/29/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

import Foundation
@_exported import NimbusKit
import UIKit

final class NimbusAdMobInterstitialAdPresenter {
    private var isRewarded: Bool
    private var adView: NimbusAdView?

    weak var adControllerDelegate: AdControllerDelegate?
    weak var adViewControllerDelegate: NimbusAdViewControllerDelegate?
    
    init(isRewarded: Bool) {
        self.isRewarded = isRewarded
    }
    
    func present(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        from viewController: UIViewController
    ) {
        adView = createAdView(with: viewController)
        guard let adView else { return }
        
        let adVC = createAdViewController(
            ad: ad,
            companionAd: companionAd,
            adView: adView
        )
        viewController.present(adVC, animated: true, completion: nil)
        adVC.renderAndStart()
    }
    
    func destroy() {
        adView?.destroy()
    }
    
    private func createAdView(with viewController: UIViewController) -> NimbusAdView? {
        let adView = NimbusAdView(adPresentingViewController: viewController)
        adView.showsSKOverlay = true
        adView.delegate = adControllerDelegate
        return adView
    }
    
    private func createAdViewController(
        ad: NimbusAd,
        companionAd: NimbusCompanionAd?,
        adView: NimbusAdView
    ) -> NimbusAdViewController {
        let adVC: NimbusAdViewController
        if isRewarded {
            adVC = NimbusAdViewController(
                adView: adView,
                ad: ad,
                companionAd: companionAd,
                closeButtonDelay: 5,
                isRewardedAd: true
            )
        } else {
            adVC = NimbusAdViewController(
                adView: adView,
                ad: ad,
                companionAd: companionAd
            )
        }
        adVC.delegate = adViewControllerDelegate
        adVC.modalPresentationStyle = .fullScreen
        
        adView.adPresentingViewController = adVC

        return adVC
    }
}
