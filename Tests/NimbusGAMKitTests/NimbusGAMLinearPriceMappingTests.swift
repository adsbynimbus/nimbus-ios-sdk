//
//  NimbusGAMLinearPriceMappingTests.swift
//  NimbusGAMKitTests
//
//  Created by Inder Dhir on 6/15/21.
//  Copyright © 2021 Timehop. All rights reserved.
//

@testable import NimbusGAMKit
import XCTest

final class NimbusGAMLinearPriceMappingTests: XCTestCase {

    func testBannerDefault() {
        let mapping = NimbusGAMLinearPriceMapping.banner()
        XCTAssertEqual(mapping.granularities.count, 4)
        XCTAssertEqual(
            mapping.granularities[0],
            NimbusGAMLinearPriceGranularity(min: 0, max: 300, step: 1)
        )
        XCTAssertEqual(
            mapping.granularities[1],
            NimbusGAMLinearPriceGranularity(min: 300, max: 800, step: 5)
        )
        XCTAssertEqual(
            mapping.granularities[2],
            NimbusGAMLinearPriceGranularity(min: 800, max: 2000, step: 50)
        )
        XCTAssertEqual(
            mapping.granularities[3],
            NimbusGAMLinearPriceGranularity(min: 2000, max: 3500, step: 100)
        )
    }
    
    func testFullscreenDefault() {
        let mapping = NimbusGAMLinearPriceMapping.fullscreen()
        XCTAssertEqual(mapping.granularities.count, 2)
        XCTAssertEqual(
            mapping.granularities[0],
            NimbusGAMLinearPriceGranularity(min: 0, max: 3500, step: 5)
        )
        XCTAssertEqual(
            mapping.granularities[1],
            NimbusGAMLinearPriceGranularity(min: 3500, max: 6000, step: 100)
        )
    }
}
