//
//  NimbusUnityRequestInterceptor.swift
//  NimbusUnityKitTests
//
//  Created by Inder Dhir on 12/13/21.
//  Copyright © 2021 Timehop. All rights reserved.
//

@testable import NimbusUnityKit
import UnityAds
import XCTest

final class NimbusUnityRequestInterceptorTests: XCTestCase {

    let deviceWidth = Int(UIScreen.main.bounds.width)
    let deviceHeight = Int(UIScreen.main.bounds.height)

    override func setUp() {
        super.setUp()

        Nimbus.shared.testMode = false
    }

    func test_unity_request_withoutRewardedRequest() {
        let request = NimbusRequest.forVideoAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil

        let requestInterceptor = StubNimbusUnityRequestInterceptor(gameId: "gameId")
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
                    "video": [
                        "protocols": [2, 3, 5, 6],
                        "w": deviceWidth,
                        "mimes": ["video/mp4", "video/3gpp", "application/x-mpegurl"],
                        "pos": 0,
                        "h": deviceHeight
                    ],
                    "ext": [
                        "position": "position",
                    ]
                ]
            ]
        ]

        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }

    func test_unity_request_witRewardedRequest() {
        let request = NimbusRequest.forRewardedVideo(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil

        let requestInterceptor = StubNimbusUnityRequestInterceptor(gameId: "gameId")
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
                "hwv": UIDevice.current.nimbusModelName,
                "connectiontype": Nimbus.shared.connectionType.rawValue,
                "ifa": "ifa",
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "imp": [
                [
                    "video": [
                        "protocols": [2, 3, 5, 6],
                        "w": deviceWidth,
                        "mimes": ["video/mp4", "video/3gpp", "application/x-mpegurl"],
                        "pos": 7,
                        "h": deviceHeight,
                        "companionad": [
                            [
                                "w": 320,
                                "h": 480,
                                "vcm": 1
                            ]
                        ],
                        "ext": [
                            "is_rewarded": 1
                        ]
                    ],
                    "instl": 1,
                    "ext": [
                        "position": "position",
                    ]
                ]
            ],
            "user": [
                "ext": [
                    "unity_buyeruid": "token"
                ]
            ]
        ]

        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
}
