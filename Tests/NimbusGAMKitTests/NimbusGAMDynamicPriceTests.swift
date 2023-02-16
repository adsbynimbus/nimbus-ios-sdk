//
//  NimbusGAMDynamicPriceTests.swift
//  NimbusGAMKitTests
//
//  Created by Inder Dhir on 11/12/20.
//  Copyright © 2020 Timehop. All rights reserved.
//

@testable import NimbusGAMKit
import XCTest
import GoogleMobileAds

final class NimbusGAMDynamicPriceTests: XCTestCase {
    
    private let bannerView = GAMBannerView(adSize: GADAdSizeBanner)
    
    override func setUp() {
        super.setUp()
        bannerView.adUnitID = "adUnitId"
    }
    
    func test_init() {
        let linearPriceGran = NimbusGAMLinearPriceGranularity(min: 10, max: 200)
        XCTAssertEqual(linearPriceGran.min, 10)
        XCTAssertEqual(linearPriceGran.max, 200)
        XCTAssertEqual(linearPriceGran.step, 20)
    }

    func test_comparable() {
        var linearPriceGran1 = NimbusGAMLinearPriceGranularity(min: 10, max: 200)
        var linearPriceGran2 = NimbusGAMLinearPriceGranularity(min: 20, max: 100)
        XCTAssertTrue(linearPriceGran1 < linearPriceGran2)

        linearPriceGran1 = NimbusGAMLinearPriceGranularity(min: 10, max: 200)
        linearPriceGran2 = NimbusGAMLinearPriceGranularity(min: 10, max: 100)
        XCTAssertEqual(linearPriceGran1, linearPriceGran2)

        linearPriceGran1 = NimbusGAMLinearPriceGranularity(min: 20, max: 100, step: 10)
        linearPriceGran2 = NimbusGAMLinearPriceGranularity(min: 10, max: 200, step: 20)
        XCTAssertTrue(linearPriceGran1 > linearPriceGran2)
    }

    func test_keywordsPresent_static() {
        let linearPriceGran1 = NimbusGAMLinearPriceGranularity(min: 10, max: 200)
        let linearPriceGran2 = NimbusGAMLinearPriceGranularity(min: 20, max: 100)
        let mapping = NimbusGAMLinearPriceMapping(
            granularities: [linearPriceGran1, linearPriceGran2]
        )

        let ad = createNimbusAd(type: .static)
        let request = GAMRequest()
        let dynamicPrice = NimbusGAMDynamicPrice(request: request, mapping: mapping)

        let manager = NimbusRequestManager()
        manager.delegate = dynamicPrice
        manager.delegate?.didCompleteNimbusRequest(
            request: NimbusRequest.forInterstitialAd(position: "position1"),
            ad: ad
        )

        XCTAssertEqual(request.customTargeting?["na_id"], ad.auctionId)
        XCTAssertNil(request.customTargeting?["na_bid_video"])
        XCTAssertNil(request.customTargeting?["na_duration"])
    }

    func test_keywordsPresent_video() {
        let linearPriceGran1 = NimbusGAMLinearPriceGranularity(min: 10, max: 200)
        let linearPriceGran2 = NimbusGAMLinearPriceGranularity(min: 20, max: 100)
        let mapping = NimbusGAMLinearPriceMapping(
            granularities: [linearPriceGran1, linearPriceGran2]
        )

        let ad = createNimbusAd(type: .video)
        let request = GAMRequest()
        let dynamicPrice = NimbusGAMDynamicPrice(request: request, mapping: mapping)

        let manager = NimbusRequestManager()
        manager.delegate = dynamicPrice
        manager.delegate?.didCompleteNimbusRequest(
            request: NimbusRequest.forInterstitialAd(position: "position1"),
            ad: ad
        )

        XCTAssertEqual(request.customTargeting?["na_id"], ad.auctionId)
        XCTAssertEqual(request.customTargeting?["na_bid_video"], mapping.getKeywords(ad: ad))
        XCTAssertEqual(request.customTargeting?["na_duration"], String(ad.duration ?? -1))
    }

    func test_keywordsPresent_existingKeywords() {
        let linearPriceGran1 = NimbusGAMLinearPriceGranularity(min: 10, max: 200)
        let linearPriceGran2 = NimbusGAMLinearPriceGranularity(min: 20, max: 100)
        let mapping = NimbusGAMLinearPriceMapping(
            granularities: [linearPriceGran1, linearPriceGran2]
        )

        let ad = createNimbusAd(type: .static)
        let request = GAMRequest()
        request.customTargeting = [:]
        request.customTargeting?["test_key"] = "test_value"
        let dynamicPrice = NimbusGAMDynamicPrice(request: request, mapping: mapping)

        let manager = NimbusRequestManager()
        manager.delegate = dynamicPrice
        manager.delegate?.didCompleteNimbusRequest(
            request: NimbusRequest.forInterstitialAd(position: "position1"),
            ad: ad
        )

        XCTAssertEqual(request.customTargeting?["na_id"], ad.auctionId)
        XCTAssertEqual(request.customTargeting?["na_bid"], mapping.getKeywords(ad: ad))
        XCTAssertEqual(request.customTargeting?["na_duration"], nil)
        XCTAssertEqual(request.customTargeting?["test_key"], "test_value")
    }

    func test_keywordsAbsent() {
        let mapping = NimbusGAMLinearPriceMapping(granularities: [])
        let ad = createNimbusAd(type: .video)
        let request = GAMRequest()
        let dynamicPrice = NimbusGAMDynamicPrice(request: request, mapping: mapping)

        let manager = NimbusRequestManager()
        manager.delegate = dynamicPrice
        manager.delegate?.didCompleteNimbusRequest(
            request: NimbusRequest.forInterstitialAd(position: "position1"),
            ad: ad
        )
        XCTAssertNil(request.customTargeting)
    }
    
    private func createNimbusAd(
        type: NimbusAuctionType = .static,
        dimensPresent: Bool = true
    ) -> NimbusAd {
        NimbusAd(
            position: "position",
            auctionType: type,
            bidRaw: 0,
            bidInCents: 200,
            contentType: "",
            auctionId: "123456",
            network: "network",
            markup: "markup",
            isInterstitial: true,
            placementId: "",
            duration: type == .video ? 1 : nil,
            adDimensions: dimensPresent ? NimbusAdDimensions(width: 320, height: 50) : nil,
            trackers: nil,
            isMraid: true,
            extensions: nil
        )
    }
}
