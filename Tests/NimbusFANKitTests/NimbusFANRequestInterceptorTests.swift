//
//  NimbusFANRequestInterceptorTests.swift
//  NimbusRequestingFANTests
//
//  Created by Inder Dhir on 10/4/19.
//  Copyright © 2019 Timehop. All rights reserved.
//

@testable import NimbusFANKit
import XCTest

final class NimbusFANRequestInterceptorTests: XCTestCase {
    
    let deviceWidth = Int(UIScreen.main.bounds.width)
    let deviceHeight = Int(UIScreen.main.bounds.height)
    
    override func setUp() {
        super.setUp()
        Nimbus.shared.testMode = false
    }
    
    func test_facebook_request_withoutUserPresent() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil
        
        let requestInterceptor = NimbusFANRequestInterceptor(appId: "appId", bidderToken: "bidderToken")
        requestInterceptor.modifyRequest(request: request)
        
        let expectedJsonDict: [String: Any] = [
            "format": [
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "device": [
                "make": "apple",
                "model": "model",
                "lmt": 1,
                "devicetype": 1,
                "ua": "userAgent",
                "os": "ios",
                "osv": UIDevice.current.systemVersion,
                "connectiontype": Nimbus.shared.connectionType.rawValue,
                "ifa": "ifa",
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "imp": [
                [
                    "banner": [
                        "api": [3, 5, 6],
                        "w": 320,
                        "pos": 7,
                        "h": 480
                    ],
                    "video": [
                        "protocols": [2, 3, 5, 6],
                        "w": deviceWidth,
                        "mimes": ["video/mp4", "video/3gpp", "application/x-mpegurl"],
                        "pos": 7,
                        "h": deviceHeight
                    ],
                    "instl": 1,
                    "ext": [
                        "position": "position",
                        "facebook_app_id": "appId"
                    ]
                ]
            ],
            "user": [
                "ext": [
                    "facebook_buyeruid": "bidderToken"
                ]
            ]
        ]
        
        let jsonDict = request.jsonDict()
        XCTAssertTrue(jsonDict.isEqual(to: expectedJsonDict))
    }
    
    func test_facebook_request_withUserPresent() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil
        request.user = NimbusUser(age: 24)
        
        let requestInterceptor = NimbusFANRequestInterceptor(appId: "appId", bidderToken: "bidderToken")
        requestInterceptor.modifyRequest(request: request)
        
        let expectedJsonDict: [String: Any] = [
            "format": [
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "device": [
                "make": "apple",
                "model": "model",
                "lmt": 1,
                "devicetype": 1,
                "ua": "userAgent",
                "os": "ios",
                "osv": UIDevice.current.systemVersion,
                "connectiontype": Nimbus.shared.connectionType.rawValue,
                "ifa": "ifa",
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "imp": [
                [
                    "banner": [
                        "api": [3, 5, 6],
                        "w": 320,
                        "pos": 7,
                        "h": 480
                    ],
                    "video": [
                        "protocols": [2, 3, 5, 6],
                        "w": deviceWidth,
                        "mimes": ["video/mp4", "video/3gpp", "application/x-mpegurl"],
                        "pos": 7,
                        "h": deviceHeight
                    ],
                    "instl": 1,
                    "ext": [
                        "position": "position",
                        "facebook_app_id": "appId"
                    ]
                ]
            ],
            "user": [
                "age": 24,
                "ext": [
                    "facebook_buyeruid": "bidderToken"
                ]
            ]
        ]
        
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
    
    func test_facebook_request_testAd_withTestMode() {
        Nimbus.shared.testMode = true
        
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil
        
        let requestInterceptor = NimbusFANRequestInterceptor(
            appId: "appId",
            bidderToken: "bidderToken"
        )
        requestInterceptor.forceTestAd = true
        requestInterceptor.modifyRequest(request: request)
        
        let expectedJsonDict: [String: Any] = [
            "format": [
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "device": [
                "make": "apple",
                "model": "model",
                "lmt": 1,
                "devicetype": 1,
                "ua": "userAgent",
                "os": "ios",
                "osv": UIDevice.current.systemVersion,
                "connectiontype": Nimbus.shared.connectionType.rawValue,
                "ifa": "ifa",
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "imp": [
                [
                    "banner": [
                        "api": [3, 5, 6],
                        "w": 320,
                        "pos": 7,
                        "h": 480
                    ],
                    "video": [
                        "protocols": [2, 3, 5, 6],
                        "w": deviceWidth,
                        "mimes": ["video/mp4", "video/3gpp", "application/x-mpegurl"],
                        "pos": 7,
                        "h": deviceHeight
                    ],
                    "instl": 1,
                    "ext": [
                        "position": "position",
                        "facebook_app_id": "appId",
                        "facebook_test_ad_type": "IMG_16_9_LINK"
                    ]
                ]
            ],
            "user": [
                "ext": [
                    "facebook_buyeruid": "bidderToken"
                ]
            ]
        ]
        
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
    
    func test_facebook_request_testAd_withoutTestMode() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil
        
        let requestInterceptor = NimbusFANRequestInterceptor(
            appId: "appId",
            bidderToken: "bidderToken"
        )
        requestInterceptor.forceTestAd = true
        requestInterceptor.modifyRequest(request: request)
        
        let expectedJsonDict: [String: Any] = [
            "format": [
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "device": [
                "make": "apple",
                "model": "model",
                "lmt": 1,
                "devicetype": 1,
                "ua": "userAgent",
                "os": "ios",
                "osv": UIDevice.current.systemVersion,
                "connectiontype": Nimbus.shared.connectionType.rawValue,
                "ifa": "ifa",
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "imp": [
                [
                    "banner": [
                        "api": [3, 5, 6],
                        "w": 320,
                        "pos": 7,
                        "h": 480
                    ],
                    "video": [
                        "protocols": [2, 3, 5, 6],
                        "w": deviceWidth,
                        "mimes": ["video/mp4", "video/3gpp", "application/x-mpegurl"],
                        "pos": 7,
                        "h": deviceHeight
                    ],
                    "instl": 1,
                    "ext": [
                        "position": "position",
                        "facebook_app_id": "appId"
                    ]
                ]
            ],
            "user": [
                "ext": [
                    "facebook_buyeruid": "bidderToken"
                ]
            ]
        ]
        
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
}
