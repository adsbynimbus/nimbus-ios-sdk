//
//  NimbusFANAdController.swift
//  NimbusRenderKit
//
//  Created on 1/30/20.
//  Copyright © 2020 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRenderKit
import FBAudienceNetwork

final class NimbusFANAdController: NimbusAdController,
                                   FBNativeAdDelegate,
                                   FBInterstitialAdDelegate,
                                   FBRewardedVideoAdDelegate,
                                   FBAdViewDelegate {

    weak var adRendererDelegate: NimbusFANAdRendererDelegate?
    var fbAdView: FBAdView?
    var fbInterstitialAd: FBInterstitialAd?
    var fbNativeAd: FBNativeAd?
    var fbRewardedVideoAd: FBRewardedVideoAd?

    /// Determines whether ad has registered an impression
    private var hasRegisteredAdImpression = false

    private var isAdVisible = false
    
    private var is320by50Banner = false
    private var fbAdSize: FBAdSize?
    
    init(
        ad: NimbusAd,
        container: UIView,
        logger: Logger,
        isBlocking: Bool,
        isRewarded: Bool,
        delegate: (any AdControllerDelegate)?,
        adRendererDelegate: NimbusFANAdRendererDelegate?,
        adPresentingViewController: UIViewController?
    ) {
        self.adRendererDelegate = adRendererDelegate
        
        super.init(
            ad: ad,
            isBlocking: isBlocking,
            isRewarded: isRewarded,
            logger: logger,
            container: container,
            delegate: delegate,
            adPresentingViewController: adPresentingViewController
        )
    }
    
    func load() {
        guard let placementId = ad.placementId else {
            sendNimbusError(NimbusRenderError.adRenderingFailed(message: "Placement id not valid for Meta ad"))
            return
        }
        
        guard let adType else {
            sendNimbusError(NimbusRenderError.invalidAdType)
            return
        }
        
        switch adType {
        case .native:
            fbNativeAd = FBNativeAd(placementID: placementId)
            fbNativeAd?.delegate = self

            if ad.markup.isEmpty {
                if Nimbus.shared.testMode {
                    // Testing Facebook native ad rendering on the client
                    fbNativeAd?.loadAd()
                } else {
                    sendNimbusError(NimbusRenderError.adRenderingFailed(message: "No markup present to render Meta native ad"))
                }
            } else {
                fbNativeAd?.loadAd(withBidPayload: ad.markup)
            }

        case .interstitial:
            fbInterstitialAd = FBInterstitialAd(placementID: placementId)
            fbInterstitialAd?.delegate = self

            if ad.markup.isEmpty {
                if Nimbus.shared.testMode {
                    // Testing Facebook interstitial ad rendering on the client
                    fbInterstitialAd?.load()
                } else {
                    sendNimbusError(NimbusRenderError.adRenderingFailed(message: "No markup present to render Meta native ad"))
                }
            } else {
                fbInterstitialAd?.load(withBidPayload: ad.markup)
            }

        case .banner:
            switch ad.adDimensions?.height {
            case 90: fbAdSize = kFBAdSizeHeight90Banner
            case 250: fbAdSize = kFBAdSizeHeight250Rectangle
            default:
                // Old integration also used to default to 320x50
                fbAdSize = kFBAdSizeHeight50Banner
                is320by50Banner = ad.adDimensions?.width == 320 && ad.adDimensions?.height == 50
            }
            
            loadBannerAd()
        case .rewarded:
            fbRewardedVideoAd = FBRewardedVideoAd(placementID: placementId)
            fbRewardedVideoAd?.delegate = self
            
            if ad.markup.isEmpty {
                if Nimbus.shared.testMode {
                    // Testing Facebook interstitial ad rendering on the client
                    fbRewardedVideoAd?.load()
                } else {
                    sendNimbusError(NimbusRenderError.adRenderingFailed(message: "No markup present to render Meta interstitial ad"))
                }
            } else {
                fbRewardedVideoAd?.load(withBidPayload: ad.markup)
            }
        @unknown default:
            sendNimbusError(NimbusRenderError.invalidAdType)
        }
    }
    
    private func loadBannerAd() {
        // This is caught at init before this function ever gets called
        guard let placementId = ad.placementId, let fbAdSize else { return }
        
        fbAdView = FBAdView(
            placementID: placementId,
            adSize: fbAdSize,
            rootViewController: adPresentingViewController
        )
        fbAdView?.delegate = self

        if ad.markup.isEmpty {
            if Nimbus.shared.testMode {
                // Testing Facebook banner ad rendering on the client
                fbAdView?.loadAd()
            } else {
                sendNimbusError(NimbusRenderError.adRenderingFailed(message: "No markup present to render Meta banner ad"))
            }
        } else {
            fbAdView?.loadAd(withBidPayload: ad.markup)
        }
    }
    
    // MARK: - AdController overrides

    override func destroy() {
        guard adState != .destroyed else { return }
        
        adState = .destroyed
        fbNativeAd?.unregisterView()
        fbNativeAd = nil
    }
    
    // MARK: - FBNativeAdDelegate

    /// :nodoc:
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        logger.log("Meta native ad loaded", level: .debug)

        guard nativeAd.isAdValid else {
            sendNimbusError(NimbusRenderError.adRenderingFailed(message: "Meta native ad is invalid"))
            return
        }

        guard let container else {
            sendNimbusError(NimbusRenderError.adRenderingFailed(message: "Container view not found for Meta native ad"))
            return
        }

        let fbNativeAdView: UIView
        if let customView = adRendererDelegate?.customViewForRendering(container: container, nativeAd: nativeAd) {
            fbNativeAdView = customView
        } else {
            fbNativeAdView = FBNativeAdView(nativeAd: nativeAd, with: .dynamic)
        }

        fbNativeAdView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(fbNativeAdView)
        NSLayoutConstraint.activate([
            fbNativeAdView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            fbNativeAdView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            fbNativeAdView.topAnchor.constraint(equalTo: container.topAnchor),
            fbNativeAdView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        sendNimbusEvent(.loaded)

        fbNativeAd = nil
    }

    /// :nodoc:
    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        logger.log("Meta native ad will log impression", level: .debug)

        hasRegisteredAdImpression = true

        sendNimbusEvent(.impression)
    }

    /// :nodoc:
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        logger.log("Meta native ad failed with error: \(error.localizedDescription)", level: .error)

        sendNimbusError(NimbusRenderError.adRenderingFailed(message: error.localizedDescription))
    }

    /// :nodoc:
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        logger.log("Meta native ad clicked", level: .debug)

        sendNimbusEvent(.clicked)
    }
    
    // MARK: - FBInterstitialAdDelegate

    /// :nodoc:
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        logger.log("Meta interstitial ad loaded", level: .debug)

        guard interstitialAd.isAdValid else {
            delegate?.didReceiveNimbusError(
                controller: self,
                error: NimbusRenderError.adRenderingFailed(message: "Meta interstitial ad is invalid")
            )
            return
        }

        sendNimbusEvent(.loaded)

        interstitialAd.show(fromRootViewController: adPresentingViewController)

        fbInterstitialAd = nil
    }

    /// :nodoc:
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        logger.log("Meta interstitial ad failed with error: \(error.localizedDescription)", level: .error)

        sendNimbusError(NimbusRenderError.adRenderingFailed(message: error.localizedDescription))
    }

    /// :nodoc:
    func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
        logger.log("Meta interstitial ad will log impression", level: .debug)

        sendNimbusEvent(.impression)
    }

    /// :nodoc:
    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        logger.log("Meta interstitial ad clicked", level: .debug)

        sendNimbusEvent(.clicked)
    }
    
    /// :nodoc:
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        logger.log("Meta interstitial ad closed", level: .debug)

        sendNimbusEvent(.destroyed)
    }
    
    // MARK: - FBRewardedVideoAdDelegate
        
    /// :nodoc:
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
        logger.log("FBRewardedAd loaded", level: .debug)

        guard rewardedVideoAd.isAdValid else {
            sendNimbusError(NimbusRenderError.adRenderingFailed(message: "Meta rewarded ad is invalid"))
            return
        }
        
        guard let presentingVC = adPresentingViewController else {
            sendNimbusError(NimbusRenderError.adRenderingFailed(message: "AdPresentingViewController is nil for Meta rewarded ad"))
            return
        }

        sendNimbusEvent(.loaded)

        rewardedVideoAd.show(fromRootViewController: presentingVC)

        fbRewardedVideoAd = nil
    }
    
    /// :nodoc:
    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
        logger.log("FBRewardedVideoAd failed with error: \(error.localizedDescription)", level: .error)

        sendNimbusError(NimbusRenderError.adRenderingFailed(message: error.localizedDescription))
    }
    
    /// :nodoc:
    func rewardedVideoAdWillLogImpression(_ rewardedVideoAd: FBRewardedVideoAd) {
        logger.log("FBRewardedVideoAd will log impression", level: .debug)

        sendNimbusEvent(.impression)
    }
    
    /// :nodoc:
    func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
        logger.log("FBRewardedVideoAd clicked", level: .debug)

        sendNimbusEvent(.clicked)
    }
    
    func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
        logger.log("FBRewardedVideoAd completed", level: .debug)

        sendNimbusEvent(.completed)
    }
    
    func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        logger.log("FBRewardedVideoAd closed", level: .debug)

        sendNimbusEvent(.destroyed)
    }
    
    // MARK: - FBAdViewDelegate

    /// :nodoc:
    func adViewDidLoad(_ adView: FBAdView) {
        logger.log("FBAdView loaded", level: .debug)

        guard adView.isAdValid else {
            sendNimbusError(NimbusRenderError.adRenderingFailed(message: "Meta banner ad is invalid"))
            return
        }

        guard let container else {
            sendNimbusError(NimbusRenderError.adRenderingFailed(message: "Container view not found for Meta banner ad"))
            return
        }

        adView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(adView)
        NSLayoutConstraint.activate([
            adView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            adView.topAnchor.constraint(equalTo: container.topAnchor),
            adView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        sendNimbusEvent(.loaded)
    }

    /// :nodoc:
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        logger.log("FBAdView failed with error: \(error.localizedDescription)", level: .error)
        
        if is320by50Banner {
            // Retry with the old banner size
            is320by50Banner = false
            fbAdSize = kFBAdSizeHeight50Banner
            loadBannerAd()
        } else {
            sendNimbusError(NimbusRenderError.adRenderingFailed(message: error.localizedDescription))
        }
    }

    /// :nodoc:
    func adViewWillLogImpression(_ adView: FBAdView) {
        logger.log("FBAdView will log impression", level: .debug)

        sendNimbusEvent(.impression)
    }

    /// :nodoc:
    func adViewDidClick(_ adView: FBAdView) {
        logger.log("FBAdView clicked", level: .debug)

        sendNimbusEvent(.clicked)
    }
}
