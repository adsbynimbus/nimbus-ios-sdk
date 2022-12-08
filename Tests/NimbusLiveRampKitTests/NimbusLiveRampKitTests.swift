//
//  NimbusLiveRampKitTests.swift
//  NimbusLiveRampKitTests
//
//  Created by Victor Takai on 20/07/22.
//  Copyright © 2022 Timehop. All rights reserved.
//

import XCTest
import LRAtsSDK
@testable import NimbusRequestKit
@testable import NimbusLiveRampKit

class NimbusLiveRampKitTests: XCTestCase {
    
    let configId = "012345"
    let email = "test@email.com"
    let phoneNumber = "15005550000"
    
    func testInitInterceptorWithEmail() {
        let delegate = MockNimbusLiveRampInterceptorDelegate()
        let interceptor = NimbusLiveRampInterceptor(
            configId: configId,
            email: email,
            isTestMode: true,
            delegate: delegate
        )
        
        XCTAssertNotNil(interceptor.email)
        XCTAssertEqual(interceptor.email!, email)
        XCTAssertNil(interceptor.phoneNumber)
        
        XCTAssertTrue(delegate.didTryToInitializeLiveRamp)
        XCTAssertNil(delegate.didInitializeLiveRampError)
        
        XCTAssertTrue(delegate.didTryToFetchLiveRampEnvelope)
        XCTAssertNil(delegate.didFetchLiveRampEnvelopeError)
    }
    
    func testInitInterceptorWithPhoneNumber() {
        let delegate = MockNimbusLiveRampInterceptorDelegate()
        let interceptor = NimbusLiveRampInterceptor(
            configId: configId,
            phoneNumber: phoneNumber,
            isTestMode: true,
            delegate: delegate
        )
        
        XCTAssertNotNil(interceptor.phoneNumber)
        XCTAssertEqual(interceptor.phoneNumber!, phoneNumber)
        XCTAssertNil(interceptor.email)
        
        XCTAssertTrue(delegate.didTryToInitializeLiveRamp)
        XCTAssertNil(delegate.didInitializeLiveRampError)
        
        XCTAssertTrue(delegate.didTryToFetchLiveRampEnvelope)
        XCTAssertNil(delegate.didFetchLiveRampEnvelopeError)
    }
    
    func testHasConsentForNoLegislation() {
        XCTAssertEqual(LRAts.shared.hasConsentForNoLegislation, false)
        
        let _ = NimbusLiveRampInterceptor(
            configId: configId,
            email: email,
            hasConsentForNoLegislation: true,
            isTestMode: true
        )
        
        XCTAssertEqual(LRAts.shared.hasConsentForNoLegislation, true)
    }
    
    func testModifyRequestWithNoExtensions() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.user = NimbusUser()
        
        XCTAssertNil(request.user?.extensions)
        
        let interceptor = NimbusLiveRampInterceptor(
            configId: configId,
            phoneNumber: phoneNumber,
            isTestMode: true
        )
        interceptor.liveRampEnvelope = "envelope"
        interceptor.modifyRequest(request: request)
        
        guard let extensionsJsonDict = request.user?.extensions?.jsonDict() else {
            XCTFail("Could not find extensions for request")
            return
        }
        
        let expectedJsonDict = [
            "eids": [[
                "source": "liveramp.com",
                "uids": [[
                    "id": "envelope",
                    "ext": ["rtiPartner": "idl"]
                ]]
            ]]
        ]
        
        XCTAssertTrue(extensionsJsonDict.isEqual(to: expectedJsonDict))
    }
    
    func testModifyRequestWithExistingLiveRampDataInExtensions() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        var user = NimbusUser()
        
        let originalEids = [
            ["source": "extra.eid"],
            [
                "source": "liveramp.com",
                "uids": [
                    [
                        "id": "123456789",
                        "ext": ["rtiPartner": "idl"]
                    ]
                ]
            ]
        ]
        
        user.extensions = ["eids": NimbusCodable(originalEids)]
        request.user = user
        
        let interceptor = NimbusLiveRampInterceptor(
            configId: configId,
            phoneNumber: phoneNumber,
            isTestMode: true
        )
        interceptor.liveRampEnvelope = "envelope"
        interceptor.modifyRequest(request: request)
        
        guard let extensionsJsonDict = request.user?.extensions?.jsonDict() else {
            XCTFail("Could not find extensions for request")
            return
        }
        
        let expectedJsonDict = [
            "eids": [
                ["source": "extra.eid"],
                [
                    "source": "liveramp.com",
                    "uids": [
                        [
                            "id": "envelope",
                            "ext": ["rtiPartner": "idl"]
                        ]
                    ]
                ]
            ]
        ]
        
        XCTAssertTrue(extensionsJsonDict.isEqual(to: expectedJsonDict))
    }
    
    func testModifyRequestWithNoLiveRampDataInExtensions() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        var user = NimbusUser()
        
        let originalEids = [
            ["source": "extra1.eid"],
            ["source": "extra2.eid"],
            ["source": "extra3.eid"]
        ]
        
        user.extensions = ["eids": NimbusCodable(originalEids)]
        request.user = user
        
        let interceptor = NimbusLiveRampInterceptor(
            configId: configId,
            phoneNumber: phoneNumber,
            isTestMode: true
        )
        interceptor.liveRampEnvelope = "envelope"
        interceptor.modifyRequest(request: request)
        
        guard let extensionsJsonDict = request.user?.extensions?.jsonDict() else {
            XCTFail("Could not find extensions for request")
            return
        }
        
        let expectedJsonDict = [
            "eids": [
                ["source": "extra1.eid"],
                ["source": "extra2.eid"],
                ["source": "extra3.eid"],
                [
                    "source": "liveramp.com",
                    "uids": [
                        [
                            "id": "envelope",
                            "ext": ["rtiPartner": "idl"]
                        ]
                    ]
                ]
            ]
        ]
        
        XCTAssertTrue(extensionsJsonDict.isEqual(to: expectedJsonDict))
    }
    
    func testModifyRequestWithNoUserPresent() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        
        let interceptor = NimbusLiveRampInterceptor(
            configId: configId,
            phoneNumber: phoneNumber,
            isTestMode: true
        )
        interceptor.liveRampEnvelope = "envelope"
        interceptor.modifyRequest(request: request)
        
        guard let extensionsJsonDict = request.user?.extensions?.jsonDict() else {
            XCTFail("Could not find extensions for request")
            return
        }
        
        let expectedJsonDict = [
            "eids": [[
                "source": "liveramp.com",
                "uids": [[
                    "id": "envelope",
                    "ext": ["rtiPartner": "idl"]
                ]]
            ]]
        ]
        
        XCTAssertTrue(extensionsJsonDict.isEqual(to: expectedJsonDict))
    }
    
    func testModifyRequestWithNoUserExtensionsPresent() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.user = .init()
        
        let interceptor = NimbusLiveRampInterceptor(
            configId: configId,
            phoneNumber: phoneNumber,
            isTestMode: true
        )
        interceptor.liveRampEnvelope = "envelope"
        interceptor.modifyRequest(request: request)
        
        guard let extensionsJsonDict = request.user?.extensions?.jsonDict() else {
            XCTFail("Could not find extensions for request")
            return
        }
        
        let expectedJsonDict = [
            "eids": [[
                "source": "liveramp.com",
                "uids": [[
                    "id": "envelope",
                    "ext": ["rtiPartner": "idl"]
                ]]
            ]]
        ]
        
        XCTAssertTrue(extensionsJsonDict.isEqual(to: expectedJsonDict))
    }
}
