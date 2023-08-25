//
//  NimbusFANAdController.swift
//  NimbusRenderKit
//
//  Created by Inder Dhir on 1/30/20.
//  Copyright © 2020 Timehop. All rights reserved.
//

@_exported import NimbusRenderKit
import FBAudienceNetwork

final class NimbusFANAdController: NSObject {

    // Visibility tracking is only necessary for non-interstitials
    let visibilityManager: VisibilityManager?

    private let ad: NimbusAd
    private let logger: Logger

    var volume = 0
    var isClickProtectionEnabled = true
    var friendlyObstructions: [UIView]? = nil
    weak var adRendererDelegate: NimbusFANAdRendererDelegate?
    var fbAdView: FBAdView?
    var fbInterstitialAd: FBInterstitialAd?
    var fbNativeAd: FBNativeAd?
    var fbRewardedVideoAd: FBRewardedVideoAd?

    /// Determines whether ad has registered an impression
    private var hasRegisteredAdImpression = false {
        didSet { triggerImpressionDelegateIfNecessary() }
    }

    private var isAdVisible = false {
        didSet { triggerImpressionDelegateIfNecessary() }
    }
    
    private var is320by50Banner = false
    private var fbAdSize: FBAdSize?

    /// Containing view for the Nimbus static ad controller (webview)
    private weak var container: NimbusAdView?
    weak var internalDelegate: AdControllerDelegate?
    public weak var delegate: AdControllerDelegate?
    private weak var adPresentingViewController: UIViewController?

    init(
        ad: NimbusAd,
        container: UIView,
        visibilityManager: VisibilityManager? = nil,
        logger: Logger,
        delegate: AdControllerDelegate,
        adRendererDelegate: NimbusFANAdRendererDelegate?,
        adPresentingViewController: UIViewController?
    ) {
        self.ad = ad
        self.container = container as? NimbusAdView
        
        if let visibilityTrackableView = container as? (UIView & VisibilityTrackable) {
            self.visibilityManager = NimbusVisibilityManager(for: visibilityTrackableView)
        } else {
            self.visibilityManager = nil
        }
        
        self.logger = logger
        self.delegate = delegate
        self.adRendererDelegate = adRendererDelegate
        self.adPresentingViewController = adPresentingViewController

        super.init()

        self.visibilityManager?.delegate = self
        self.visibilityManager?.startListeningForVisibilityChanges()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    func load() {
        guard let placementId = ad.placementId else {
            forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "Placement id not valid for Meta ad"))
            return
        }

        switch (ad.auctionType, ad.isInterstitial) {
        case (.native, _):
            fbNativeAd = FBNativeAd(placementID: placementId)
            fbNativeAd?.delegate = self

            if ad.markup.isEmpty {
                if Nimbus.shared.testMode {
                    // Testing Facebook native ad rendering on the client
                    fbNativeAd?.loadAd()
                } else {
                    forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "No markup present to render Meta native ad"))
                }
            } else {
                fbNativeAd?.loadAd(withBidPayload: ad.markup)
            }

        case (.static, true):
            fbInterstitialAd = FBInterstitialAd(placementID: placementId)
            fbInterstitialAd?.delegate = self

            if ad.markup.isEmpty {
                if Nimbus.shared.testMode {
                    // Testing Facebook interstitial ad rendering on the client
                    fbInterstitialAd?.load()
                } else {
                    forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "No markup present to render Meta native ad"))
                }
            } else {
                fbInterstitialAd?.load(withBidPayload: ad.markup)
            }

        case (.static, false):
            switch ad.adDimensions?.height {
            case 90: fbAdSize = kFBAdSizeHeight90Banner
            case 250: fbAdSize = kFBAdSizeHeight250Rectangle
            default:
                // Old integration also used to default to 320x50
                fbAdSize = kFBAdSizeHeight50Banner
                is320by50Banner = ad.adDimensions?.width == 320 && ad.adDimensions?.height == 50
            }
            
            loadBannerAd()
        case (.video, _):
            fbRewardedVideoAd = FBRewardedVideoAd(placementID: placementId)
            fbRewardedVideoAd?.delegate = self
            
            if ad.markup.isEmpty {
                if Nimbus.shared.testMode {
                    // Testing Facebook interstitial ad rendering on the client
                    fbRewardedVideoAd?.load()
                } else {
                    forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "No markup present to render Meta interstitial ad"))
                }
            } else {
                fbRewardedVideoAd?.load(withBidPayload: ad.markup)
            }

        default:
            forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "Meta Ad not supported"))
            return
        }
    }

    private func triggerImpressionDelegateIfNecessary() {
        guard let container else { return }

        container.visibilityDelegate?.didChangeVisibility(
            controller: container,
            isVisible: isAdVisible,
            hasTriggeredImpression: hasRegisteredAdImpression
        )
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
                forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "No markup present to render Meta banner ad"))
            }
        } else {
            fbAdView?.loadAd(withBidPayload: ad.markup)
        }
    }
    
    private func forwardNimbusEvent(_ event: NimbusEvent) {
        internalDelegate?.didReceiveNimbusEvent(controller: self, event: event)
        delegate?.didReceiveNimbusEvent(controller: self, event: event)
    }
    
    private func forwardNimbusError(_ error: NimbusError) {
        internalDelegate?.didReceiveNimbusError(controller: self, error: error)
        delegate?.didReceiveNimbusError(controller: self, error: error)
    }
}

// MARK: AdController

extension NimbusFANAdController: AdController {

    var adView: UIView? { nil }

    var adDuration: CGFloat { 0 }

    func start() {}

    func stop() {}

    func destroy() {
        fbNativeAd?.unregisterView()
        fbNativeAd = nil
        visibilityManager?.destroy()
    }
}

// MARK: Notifications

extension NimbusFANAdController {

    /// Ad is in foreground
    @objc private func appDidBecomeActive() {
        visibilityManager?.appDidBecomeActive()
    }

    /// Ad is in background
    @objc private func appWillResignActive() {
        visibilityManager?.appWillResignActive()
    }
}

// MARK: VisibilityManagerDelegate

extension NimbusFANAdController: VisibilityManagerDelegate {

    func didRegisterImpressionForView() {}

    func didChangeExposure(exposure: NimbusViewExposure) {
        let newVisibility = exposure.isVisible
        if isAdVisible != newVisibility {
            isAdVisible = newVisibility
        }
    }
}

// MARK: FBNativeAdDelegate

extension NimbusFANAdController: FBNativeAdDelegate {

    /// :nodoc:
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        logger.log("Meta native ad loaded", level: .debug)

        guard nativeAd.isAdValid else {
            forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "Meta native ad is invalid"))
            return
        }

        guard let container else {
            forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "Container view not found for Meta native ad"))
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
            fbNativeAdView.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
            fbNativeAdView.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
            fbNativeAdView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
            fbNativeAdView.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor)
        ])

        forwardNimbusEvent(.loaded)

        fbNativeAd = nil
    }

    /// :nodoc:
    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        logger.log("Meta native ad will log impression", level: .debug)

        hasRegisteredAdImpression = true

        forwardNimbusEvent(.impression)
    }

    /// :nodoc:
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        logger.log("Meta native ad failed with error: \(error.localizedDescription)", level: .error)

        forwardNimbusError(NimbusRenderError.adRenderingFailed(message: error.localizedDescription))
    }

    /// :nodoc:
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        logger.log("Meta native ad clicked", level: .debug)

        forwardNimbusEvent(.clicked)
    }
}

// MARK: FBInterstitialAdDelegate

extension NimbusFANAdController: FBInterstitialAdDelegate {

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

        forwardNimbusEvent(.loaded)

        interstitialAd.show(fromRootViewController: adPresentingViewController)

        fbInterstitialAd = nil
    }

    /// :nodoc:
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        logger.log("Meta interstitial ad failed with error: \(error.localizedDescription)", level: .error)

        forwardNimbusError(NimbusRenderError.adRenderingFailed(message: error.localizedDescription))
    }

    /// :nodoc:
    func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
        logger.log("Meta interstitial ad will log impression", level: .debug)

        forwardNimbusEvent(.impression)
    }

    /// :nodoc:
    func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        logger.log("Meta interstitial ad clicked", level: .debug)

        forwardNimbusEvent(.clicked)
    }
    
    /// :nodoc:
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        logger.log("Meta interstitial ad closed", level: .debug)

        forwardNimbusEvent(.destroyed)
    }
}

// MARK: FBRewardedVideoAdDelegate

extension NimbusFANAdController: FBRewardedVideoAdDelegate {
    
    /// :nodoc:
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
        logger.log("FBRewardedAd loaded", level: .debug)

        guard rewardedVideoAd.isAdValid else {
            forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "Meta rewarded ad is invalid"))
            return
        }
        
        guard let presentingVC = adPresentingViewController else {
            forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "AdPresentingViewController is nil for Meta rewarded ad"))
            return
        }

        forwardNimbusEvent(.loaded)

        rewardedVideoAd.show(fromRootViewController: presentingVC)

        fbRewardedVideoAd = nil
    }
    
    /// :nodoc:
    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
        logger.log("FBRewardedVideoAd failed with error: \(error.localizedDescription)", level: .error)

        forwardNimbusError(NimbusRenderError.adRenderingFailed(message: error.localizedDescription))
    }
    
    /// :nodoc:
    func rewardedVideoAdWillLogImpression(_ rewardedVideoAd: FBRewardedVideoAd) {
        logger.log("FBRewardedVideoAd will log impression", level: .debug)

        forwardNimbusEvent(.impression)
    }
    
    /// :nodoc:
    func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
        logger.log("FBRewardedVideoAd clicked", level: .debug)

        forwardNimbusEvent(.clicked)
    }
    
    func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
        logger.log("FBRewardedVideoAd completed", level: .debug)

        forwardNimbusEvent(.completed)
    }
    
    func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        logger.log("FBRewardedVideoAd closed", level: .debug)

        forwardNimbusEvent(.destroyed)
    }
}

// MARK: FBAdViewDelegate

extension NimbusFANAdController: FBAdViewDelegate {

    /// :nodoc:
    func adViewDidLoad(_ adView: FBAdView) {
        logger.log("FBAdView loaded", level: .debug)

        guard adView.isAdValid else {
            forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "Meta banner ad is invalid"))
            return
        }

        guard let container else {
            forwardNimbusError(NimbusRenderError.adRenderingFailed(message: "Container view not found for Meta banner ad"))
            return
        }

        adView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(adView)
        NSLayoutConstraint.activate([
            adView.leadingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor),
            adView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
            adView.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor)
        ])

        forwardNimbusEvent(.loaded)
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
            forwardNimbusError(NimbusRenderError.adRenderingFailed(message: error.localizedDescription))
        }
    }

    /// :nodoc:
    func adViewWillLogImpression(_ adView: FBAdView) {
        logger.log("FBAdView will log impression", level: .debug)

        forwardNimbusEvent(.impression)
    }

    /// :nodoc:
    func adViewDidClick(_ adView: FBAdView) {
        logger.log("FBAdView clicked", level: .debug)

        forwardNimbusEvent(.clicked)
    }
}
