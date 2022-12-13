//
//  NimbusRenderFANKitTests.swift
//  NimbusRenderFANKitTests
//
//  Created by Inder Dhir on 2/3/20.
//  Copyright © 2020 Timehop. All rights reserved.
//

@testable import NimbusFANKit
import XCTest

class NimbusRenderFANKitTests: XCTestCase {

    func testEmptyMarkup_native_disabledTestMode() {
        Nimbus.shared.testMode = false

        let ad = createNimbusAd(
            auctionType: .native,
            markup: "",
            isInterstitial: false,
            isMraid: false
        )
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let delegate = MockAdControllerDelegate()

        let _ = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertEqual(delegate.errors.count, 1)
        XCTAssertEqual(
            delegate.errors.first?.localizedDescription,
            NimbusRenderError.adRenderingFailed(message: "No markup present to render Facebook native ad").localizedDescription
        )
    }

    func testEmptyMarkup_native_enabledTestMode() {
        Nimbus.shared.testMode = true

        let ad = createNimbusAd(
            auctionType: .native,
            markup: "",
            isInterstitial: false,
            isMraid: false
        )
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let delegate = MockAdControllerDelegate()

        let controller = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertTrue(delegate.errors.isEmpty)

        XCTAssertNil(controller.fbAdView)
        XCTAssertNil(controller.fbInterstitialAd)
        XCTAssertNotNil(controller.fbNativeAd)
    }

    func testEmptyMarkup_static_disabledTestMode() {
        Nimbus.shared.testMode = false

        let ad = createNimbusAd(
            auctionType: .static,
            markup: "",
            isInterstitial: false,
            isMraid: false
        )
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let delegate = MockAdControllerDelegate()

        let _ = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertEqual(delegate.errors.count, 1)
        XCTAssertEqual(
            delegate.errors.first?.localizedDescription,
            NimbusRenderError.adRenderingFailed(message: "No markup present to render Facebook banner ad").localizedDescription
        )
    }

    func testEmptyMarkup_static_enabledTestMode() {
        Nimbus.shared.testMode = true

        let ad = createNimbusAd(
            auctionType: .static,
            markup: "",
            isInterstitial: false,
            isMraid: false
        )
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let delegate = MockAdControllerDelegate()

        let controller = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertTrue(delegate.errors.isEmpty)

        XCTAssertNotNil(controller.fbAdView)
        XCTAssertNil(controller.fbInterstitialAd)
        XCTAssertNil(controller.fbNativeAd)
    }

    func testEmptyMarkup_video_disabledTestMode() {
        Nimbus.shared.testMode = false

        let ad = createNimbusAd(
            auctionType: .video,
            markup: "",
            isInterstitial: true,
            isMraid: false
        )
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let delegate = MockAdControllerDelegate()

        let _ = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertEqual(delegate.errors.count, 1)
        XCTAssertEqual(
            delegate.errors.first?.localizedDescription,
            NimbusRenderError.adRenderingFailed(message: "No markup present to render Facebook interstitial ad").localizedDescription
        )
    }

    func testEmptyMarkup_video_enabledTestMode() {
        Nimbus.shared.testMode = true

        let ad = createNimbusAd(
            auctionType: .video,
            markup: "",
            isInterstitial: true,
            isMraid: false
        )
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let delegate = MockAdControllerDelegate()

        let controller = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertTrue(delegate.errors.isEmpty)

        XCTAssertNil(controller.fbAdView)
        XCTAssertNotNil(controller.fbInterstitialAd)
        XCTAssertNil(controller.fbNativeAd)
    }

    func testFBPlacementId() {
        Nimbus.shared.testMode = false

        let ad = createNimbusAd(
            auctionType: .native,
            markup: "nonEmptyMarkup",
            placementId: nil,
            isInterstitial: false,
            isMraid: false
        )
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let delegate = MockAdControllerDelegate()

        let _ = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: delegate,
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertEqual(delegate.errors.count, 1)
        XCTAssertEqual(
            delegate.errors.first?.localizedDescription,
            NimbusRenderError.adRenderingFailed(message: "Placement id not valid for FB ad").localizedDescription
        )
    }

    func testFBBannerAd() {
        Nimbus.shared.testMode = false

        let ad = createNimbusAd(auctionType: .static, isInterstitial: false, isMraid: true)
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let controller = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: MockAdControllerDelegate(),
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertNotNil(controller.fbAdView)
        XCTAssertNil(controller.fbInterstitialAd)
        XCTAssertNil(controller.fbNativeAd)
    }

    func testFBInterstitialAd_static() {
        Nimbus.shared.testMode = false

        let ad = createNimbusAd(auctionType: .static, isInterstitial: true, isMraid: true)
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let controller = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: MockAdControllerDelegate(),
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertNil(controller.fbAdView)
        XCTAssertNotNil(controller.fbInterstitialAd)
        XCTAssertNil(controller.fbNativeAd)
    }

    func testFBInterstitialAd_video() {
        Nimbus.shared.testMode = false

        let ad = createNimbusAd(auctionType: .video, isInterstitial: true, isMraid: false)
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let controller = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: MockAdControllerDelegate(),
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertNil(controller.fbAdView)
        XCTAssertNotNil(controller.fbInterstitialAd)
        XCTAssertNil(controller.fbNativeAd)
    }

    func testFBNativeAd() {
        Nimbus.shared.testMode = false

        let ad = createNimbusAd(auctionType: .native, isInterstitial: false, isMraid: false)
        let viewController = UIViewController()
        let view = NimbusAdView(adPresentingViewController: viewController)

        let controller = NimbusFANAdController(
            ad: ad,
            container: view,
            logger: Nimbus.shared.logger,
            delegate: MockAdControllerDelegate(),
            adRendererDelegate: nil,
            adPresentingViewController: viewController
        )

        XCTAssertNil(controller.fbAdView)
        XCTAssertNil(controller.fbInterstitialAd)
        XCTAssertNotNil(controller.fbNativeAd)
    }

    private func createNimbusAd(
        auctionType: NimbusAuctionType,
        markup: String = "",
        placementId: String? = "placementId",
        isInterstitial: Bool,
        isMraid: Bool
    ) -> NimbusAd {
        NimbusAd(
            position: "position",
            auctionType: auctionType,
            bidRaw: 0,
            bidInCents: 0,
            contentType: "",
            auctionId: "",
            network: "facebook",
            markup: markup,
            isInterstitial: isInterstitial,
            placementId: placementId,
            duration: nil,
            adDimensions: nil,
            trackers: nil,
            isMraid: isMraid,
            extensions: nil
        )
    }
}

class MockAdControllerDelegate: AdControllerDelegate {
    var errors: [NimbusError] = []

    func didRegisterImpressionForView() {}

    func didReceiveNimbusEvent(controller: AdController, event: NimbusEvent) {}

    func didReceiveNimbusError(controller: AdController, error: NimbusError) {
        errors.append(error)
    }
}
