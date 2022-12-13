//
//  NimbusAPSRequestHelperTests.swift
//  NimbusRequestAPSKitTests
//
//  Created by Inder Dhir on 9/5/22.
//  Copyright © 2022 Timehop. All rights reserved.
//

@testable import NimbusRequestAPSKit
import DTBiOSSDK
import XCTest

class NimbusAPSRequestHelperTests: XCTestCase {
    
    var requestHelper: NimbusAPSRequestHelper!
    fileprivate var requestManager: MockNimbusAPSRequestManager!

    override func setUpWithError() throws {
        requestManager = MockNimbusAPSRequestManager()
        requestHelper = NimbusAPSRequestHelper(
            appKey: "appKey",
            requestManager: requestManager,
            timeoutInSeconds: 0.5
        )
    }

    func test_APSAdSlot_video() throws {
        XCTAssertTrue(requestHelper.adSizes.isEmpty)
        
        requestHelper.addAPSSlot(slotUUID: "slotUUID", width: 320, height: 480, isVideo: true)
        
        XCTAssertFalse(requestHelper.adSizes.isEmpty)
        XCTAssertEqual(requestHelper.adSizes.first?.adType.rawValue, 0)
    }
    
    func test_APSAdSlot_staticInterstitial_portrait() {
        XCTAssertTrue(requestHelper.adSizes.isEmpty)
        
        requestHelper.addAPSSlot(slotUUID: "slotUUID", width: 320, height: 480, isVideo: false)
        
        XCTAssertFalse(requestHelper.adSizes.isEmpty)
        XCTAssertEqual(requestHelper.adSizes.first?.adType.rawValue, 2)
    }
    
    func test_APSAdSlot_staticInterstitial_landscape() {
        XCTAssertTrue(requestHelper.adSizes.isEmpty)
        
        requestHelper.addAPSSlot(slotUUID: "slotUUID", width: 480, height: 320, isVideo: false)
        
        XCTAssertFalse(requestHelper.adSizes.isEmpty)
        XCTAssertEqual(requestHelper.adSizes.first?.adType.rawValue, 2)
    }
    
    func testFetchParams_withVideoPresent_excludeVideo() {
        requestHelper.addAPSSlot(slotUUID: "slotUUID", width: 320, height: 480, isVideo: true)
        _ = requestHelper.fetchAPSParams(width: 320, height: 480, includeVideo: false)
        
        XCTAssertTrue(requestManager.adSizes.isEmpty)
    }
    
    func testFetchParams_withVideoPresent_includeVideo() {
        requestHelper.addAPSSlot(slotUUID: "slotUUID", width: 320, height: 480, isVideo: true)
        _ = requestHelper.fetchAPSParams(width: 320, height: 480, includeVideo: true)
        
        XCTAssertFalse(requestManager.adSizes.isEmpty)
    }
    
    func testFetchParams_withVideoAndInterstitials() {
        requestHelper.addAPSSlot(slotUUID: "slotUUID", width: 320, height: 480, isVideo: true)
        requestHelper.addAPSSlot(slotUUID: "slotUUID2", width: 320, height: 480, isVideo: false)
        requestHelper.addAPSSlot(slotUUID: "slotUUID3", width: 480, height: 320, isVideo: false)

        _ = requestHelper.fetchAPSParams(width: 320, height: 480, includeVideo: true)
        
        XCTAssertEqual(requestManager.adSizes.count, 3)
    }
    
    func testFetchParams_forBanner_withVideoAndInterstitial_withOtherValidAndInvalidSizes() {
        requestHelper.addAPSSlot(slotUUID: "slotUUID", width: 320, height: 480, isVideo: true)
        requestHelper.addAPSSlot(slotUUID: "slotUUID2", width: 320, height: 480, isVideo: false)
        
        requestHelper.addAPSSlot(slotUUID: "slotUUID3", width: 300, height: 50, isVideo: false)
        requestHelper.addAPSSlot(slotUUID: "slotUUID4", width: 300, height: 250, isVideo: false)

        _ = requestHelper.fetchAPSParams(width: 300, height: 50, includeVideo: true)
        
        XCTAssertEqual(requestManager.adSizes.count, 2)
    }
    
    func testFetchParams_forInterstitial_withVideoAndInterstitial_withOtherValidAndInvalidSizes() {
        requestHelper.addAPSSlot(slotUUID: "slotUUID", width: 320, height: 480, isVideo: true)
        requestHelper.addAPSSlot(slotUUID: "slotUUID2", width: 320, height: 480, isVideo: false)
        
        requestHelper.addAPSSlot(slotUUID: "slotUUID3", width: 300, height: 50, isVideo: false)
        requestHelper.addAPSSlot(slotUUID: "slotUUID4", width: 300, height: 250, isVideo: false)

        _ = requestHelper.fetchAPSParams(width: 320, height: 480, includeVideo: true)
        
        XCTAssertEqual(requestManager.adSizes.count, 2)
    }
}

private class MockNimbusAPSRequestManager: APSRequestManagerType {
    var usPrivacyString: String? = "test"
    
    var adSizes: [DTBAdSize] = []
    
    func loadAdsSync(for adSizes: [DTBAdSize]) -> [[AnyHashable: Any]] {
        self.adSizes = adSizes
        return []
    }
}
