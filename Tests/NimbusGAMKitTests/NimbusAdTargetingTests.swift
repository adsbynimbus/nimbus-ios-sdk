//
//  NimbusAdTargetingTests.swift
//  NimbusGAMKitTests
//
//  Created by Inder Dhir on 8/12/22.
//  Copyright © 2022 Timehop. All rights reserved.
//

@testable import NimbusGAMKit
import GoogleMobileAds
import XCTest

class NimbusAdTargetingTests: XCTestCase {
    
    func test_keywordsPresent_static() {
        let ad = createNimbusAd(type: .static)
        let request = GAMRequest()
        ad.applyDynamicPrice(into: request)

        XCTAssertEqual(request.customTargeting?["na_id"], ad.auctionId)
        XCTAssertNil(request.customTargeting?["na_bid_video"])
        XCTAssertNil(request.customTargeting?["na_duration"])
    }

    func test_keywordsPresent_video() {
        let ad = createNimbusAd(type: .video)
        let request = GAMRequest()
        
        let mapping = NimbusGAMLinearPriceMapping.banner()
        ad.applyDynamicPrice(into: request, mapping: mapping)

        XCTAssertEqual(request.customTargeting?["na_id"], ad.auctionId)
        XCTAssertEqual(request.customTargeting?["na_bid_video"], mapping.getKeywords(ad: ad))
        XCTAssertEqual(request.customTargeting?["na_duration"], String(ad.duration ?? -1))
    }

    func test_keywordsPresent_existingKeywords() {
        let ad = createNimbusAd(type: .static)
        let request = GAMRequest()
        request.customTargeting = [:]
        request.customTargeting?["test_key"] = "test_value"

        let mapping = NimbusGAMLinearPriceMapping.banner()
        ad.applyDynamicPrice(into: request, mapping: mapping)
//
        XCTAssertEqual(request.customTargeting?["na_id"], ad.auctionId)
        XCTAssertEqual(request.customTargeting?["na_bid"], mapping.getKeywords(ad: ad))
        XCTAssertEqual(request.customTargeting?["na_duration"], nil)
        XCTAssertEqual(request.customTargeting?["test_key"], "test_value")
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
