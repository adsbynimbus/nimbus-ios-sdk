//
//  NimbusRequestingAPSTests.swift
//  NimbusRequestingAPSTests
//
//  Created by Inder Dhir on 10/4/19.
//  Copyright © 2019 Timehop. All rights reserved.
//

@testable import NimbusRequestAPSKit
import DTBiOSSDK
import XCTest

final class NimbusRequestingAPSTests: XCTestCase {
    
    let deviceWidth = Int(UIScreen.main.bounds.width)
    let deviceHeight = Int(UIScreen.main.bounds.height)
    
    func test_aps_request_interstitial_validation() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].isInterstitial = nil

        let size = DTBAdSize(interstitialAdSizeWithSlotUUID: "slotUUID")!
        let requestInterceptor = NimbusAPSRequestInterceptor(
            appKey: "appKey",
            adSizes: [size]
        )
        let mockRequestManager = MockAPSRequestManager(sizes: [size])
        requestInterceptor.requestManager = mockRequestManager
        
        requestInterceptor.modifyRequest(request: request)
        var expectedJsonDict: [String: Any] = [
            "format": [
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "device": [
                "make": "apple",
                "model": "model",
                "devicetype": 1,
                "lmt": 1,
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
                    "ext": [
                        "position": "position"
                    ]
                ]
            ]
        ]
        
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
        
        request.impressions[0].isInterstitial = false
        requestInterceptor.modifyRequest(request: request)
        expectedJsonDict = [
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
                    "instl": 0,
                    "ext": [
                        "position": "position"
                    ]
                ]
            ]
        ]
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
        
        request.impressions[0].isInterstitial = true
        request.impressions[0].banner = nil
        
        requestInterceptor.modifyRequest(request: request)
        
        expectedJsonDict = [
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
                        "pos": 7,
                        "h": deviceHeight
                    ],
                    "instl": 1,
                    "ext": [
                        "position": "position"
                    ]
                ]
            ]
        ]
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
    
    func test_aps_request_interstitial() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil
        
        let size = DTBAdSize(interstitialAdSizeWithSlotUUID: "slotUUID")!
        let requestInterceptor = NimbusAPSRequestInterceptor(
            appKey: "appKey",
            adSizes: [size]
        )
        let mockRequestManager = MockAPSRequestManager(sizes: [size])
        requestInterceptor.requestManager = mockRequestManager
        
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
                        "aps": [
                            mockRequestManager.mockResponse
                        ]
                    ]
                ]
            ]
        ]

        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
    
    func test_aps_request_video_validation() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil
        
        let size = DTBAdSize(videoAdSizeWithPlayerWidth: 320, height: 480, andSlotUUID: "slotUUID")!
        let requestInterceptor = NimbusAPSRequestInterceptor(
            appKey: "appKey",
            adSizes: [size]
        )
        let mockRequestManager = MockAPSRequestManager(sizes: [size])
        requestInterceptor.requestManager = mockRequestManager
        
        request.impressions[0].video = nil
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
                    "instl": 1,
                    "ext": [
                        "position": "position"
                    ]
                ]
            ]
        ]
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
    
    func test_aps_request_video() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil
        
        let size = DTBAdSize(videoAdSizeWithPlayerWidth: 320, height: 480, andSlotUUID: "slotUUID")!
        let requestInterceptor = NimbusAPSRequestInterceptor(
            appKey: "appKey",
            adSizes: [size]
        )
        let mockRequestManager = MockAPSRequestManager(sizes: [size])
        requestInterceptor.requestManager = mockRequestManager

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
                        "aps": [
                            mockRequestManager.mockResponse
                        ]
                    ]
                ]
            ]
        ]
        
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
    
    func test_aps_request_display_validation() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil
        
        let size = DTBAdSize(bannerAdSizeWithWidth: 320, height: 480, andSlotUUID: "slotUUID")!
        let requestInterceptor = NimbusAPSRequestInterceptor(
            appKey: "appKey",
            adSizes: [size]
        )
        let mockRequestManager = MockAPSRequestManager(sizes: [size])
        requestInterceptor.requestManager = mockRequestManager
        
        request.impressions[0].video = nil
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
                    "instl": 1,
                    "ext": [
                        "position": "position",
                        "aps": [
                            mockRequestManager.mockResponse
                        ]
                    ]
                ]
            ]
        ]
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
    
    func test_aps_request_display() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = [NimbusAdFormat(width: 320, height: 480)]
        
        let size = DTBAdSize(videoAdSizeWithPlayerWidth: 320, height: 480, andSlotUUID: "slotUUID")!
        let requestInterceptor = NimbusAPSRequestInterceptor(
            appKey: "appKey",
            adSizes: [size]
        )
        let mockRequestManager = MockAPSRequestManager(sizes: [size])
        requestInterceptor.requestManager = mockRequestManager

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
                        "h": 480,
                        "format": [
                            ["w": 320, "h": 480]
                        ]
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
                        "aps": [
                            mockRequestManager.mockResponse
                        ]
                    ]
                ]
            ]
        ]
        
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
    
    func test_aps_request_multipleAdSizes() {
        let request = NimbusRequest.forInterstitialAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil

        let size1 = DTBAdSize(videoAdSizeWithPlayerWidth: 320, height: 480, andSlotUUID: "slotUUID")!
        let size2 = DTBAdSize(interstitialAdSizeWithSlotUUID: "slotUUID")!
        let requestInterceptor = NimbusAPSRequestInterceptor(
            appKey: "appKey",
            adSizes: [size1, size2]
        )
        let mockRequestManager = MockAPSRequestManagerMultipleSizes(sizes: [size1, size2])
        requestInterceptor.requestManager = mockRequestManager

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
                        "aps": [
                            mockRequestManager.mockResponse1,
                            mockRequestManager.mockResponse2
                        ]
                    ]
                ]
            ]
        ]

        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }

    func test_aps_request_320x50_banner_with_no_formats() {
        let request = NimbusRequest.forBannerAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"
        request.impressions[0].banner?.formats = nil

        let size = DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: "slotUUID")!
        let requestInterceptor = NimbusAPSRequestInterceptor(appKey: "appKey", adSizes: [size])
        let mockRequestManager = MockAPSRequestManager(sizes: [size])
        requestInterceptor.requestManager = mockRequestManager

        requestInterceptor.modifyRequest(request: request)

        let expectedJsonDict: [String: Any] = [
            "format": [
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "device": [
                "make": "apple",
                "model": "model",
                "devicetype": 1,
                "ua": "userAgent",
                "lmt": 1,
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
                        "pos": 1,
                        "h": 50
                    ],
                    "ext": [
                        "position": "position",
                        "aps": [
                            mockRequestManager.mockResponse
                        ]
                    ]
                ]
            ]
        ]

        print(request.jsonDict())
        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }

    func test_aps_request_320x50_banner_with_formats() {
        let request = NimbusRequest.forBannerAd(position: "position")
        request.device.userAgent = "userAgent"
        request.device.model = "model"
        request.device.advertisingId = "ifa"

        request.impressions[0].banner?.width = 400
        request.impressions[0].banner?.height = 200
        request.impressions[0].banner?.formats = [NimbusAdFormat(width: 320, height: 50)]

        let size = DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: "slotUUID")!
        let requestInterceptor = NimbusAPSRequestInterceptor(appKey: "appKey", adSizes: [size])
        let mockRequestManager = MockAPSRequestManager(sizes: [size])
        requestInterceptor.requestManager = mockRequestManager
        
        requestInterceptor.modifyRequest(request: request)

        let expectedJsonDict: [String: Any] = [
            "format": [
                "w": deviceWidth,
                "h": deviceHeight
            ],
            "device": [
                "make": "apple",
                "model": "model",
                "devicetype": 1,
                "ua": "userAgent",
                "lmt": 1,
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
                        "w": 400,
                        "pos": 1,
                        "h": 200,
                        "format": [
                            [
                                "w": 320,
                                "h": 50
                            ]
                        ]
                    ],
                    "ext": [
                        "position": "position",
                        "aps": [
                            mockRequestManager.mockResponse
                        ]
                    ]
                ]
            ]
        ]

        XCTAssertTrue(request.jsonDict().isEqual(to: expectedJsonDict))
    }
}
