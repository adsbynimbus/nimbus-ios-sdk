// swift-tools-version: 5.6

import Foundation
import PackageDescription

let package = Package(
    name: "NimbusSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
           name: "NimbusKit",
           targets: ["NimbusTarget"]),
        .library(
           name: "NimbusRenderKit",
           targets: ["NimbusRenderTarget"]),
        .library(
           name: "NimbusRenderStaticKit",
           targets: ["NimbusRenderStaticTarget"]),
        .library(
           name: "NimbusRenderVideoKit",
           targets: ["NimbusRenderVideoTarget"]),
        .library(
           name: "NimbusRenderVASTKit",
           targets: ["NimbusRenderVASTTarget"]),
        .library(
           name: "NimbusRequestKit",
           targets: ["NimbusRequestTarget"]),
        .library(
           name: "NimbusGAMKit",
           targets: ["NimbusGAMKit"]),
        .library(
           name: "NimbusAdMobKit",
           targets: ["NimbusAdMobKit"]),
        .library(
           name: "NimbusGoogleKit",
           targets: ["NimbusGoogleKit"]),
        .library(
           name: "NimbusFANKit",
           targets: ["NimbusRenderFANKit", "NimbusRequestFANKit", "FBAudienceNetwork"]),
        .library(
           name: "NimbusLiveRampKit",
           targets: ["NimbusLiveRampKit"]),
        .library(
           name: "NimbusRequestAPSKit",
           targets: ["NimbusRequestAPSKit", "DTBiOSSDK"]),
        .library(
           name: "NimbusUnityKit",
           targets: ["NimbusUnityKit", "UnityAds"]),
        .library(
           name: "NimbusVungleKit",
           targets: ["NimbusVungleKit"]),
        .library(
           name: "NimbusMintegralKit",
           targets: ["NimbusMintegralKit"]),
        .library(
           name: "NimbusMobileFuseKit",
           targets: ["NimbusMobileFuseKit"]),
        .library(
           name: "NimbusRequestAPSKit-WithoutDTBiOSSDK",
           targets: ["NimbusRequestAPSKit"]),
        .library(
           name: "NimbusFANKit-WithoutFBAudienceNetwork",
           targets: ["NimbusRenderFANKit", "NimbusRequestFANKit"]),
        .library(
           name: "NimbusUnityKit-WithoutUnityAds",
           targets: ["NimbusUnityKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LiveRamp/ats-sdk-ios.git", from: "2.5.0"),
        .package(url: "https://github.com/birdrides/mockingbird.git", from: "0.20.0"),
        .package(url: "https://github.com/Vungle/VungleAdsSDK-SwiftPackageManager.git", from: "7.4.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.7.0"),
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-interactive-media-ads-ios.git",
            from: "3.18.4"
        ),
        .package(url: "https://github.com/Mintegral-official/MintegralAdSDK-Swift-Package", from: "7.6.7"),
    ],
    targets: [
        .framework(
            name: "NimbusRenderTarget",
            dependencies: ["NimbusCoreKit", "NimbusRenderKit", "OMSDK_Adsbynimbus"]),
        .framework(
            name: "NimbusRequestTarget",
            dependencies: ["NimbusCoreKit", "NimbusRequestKit"]),
        .framework(
            name: "NimbusRenderStaticTarget",
            dependencies: ["NimbusRenderTarget", "NimbusRenderStaticKit"]),
        .framework(
            name: "NimbusRenderVideoTarget",
            dependencies: ["NimbusRenderTarget", "NimbusRenderVideoKit", .GoogleInteractiveMediaAds]),
        .framework(
            name: "NimbusRenderVASTTarget",
            dependencies: ["NimbusRenderStaticTarget", "NimbusRenderVASTKit"]),
        .framework(
            name: "NimbusTarget",
            dependencies: [
                "NimbusRequestTarget",
                "NimbusRenderTarget",
                "NimbusRenderStaticTarget",
                "NimbusRenderVideoTarget",
                "NimbusKit"
            ]),
        .target(
            name: "NimbusRenderFANKit",
            dependencies: ["NimbusRenderTarget"]),
        .target(
            name: "NimbusRequestFANKit",
            dependencies: ["NimbusRequestTarget"]),
        .target(
            name: "NimbusGAMKit",
            dependencies: ["NimbusTarget", .GoogleMobileAds]),
        .target(
            name: "NimbusAdMobKit",
            dependencies: ["NimbusTarget", .GoogleMobileAds]),
        .target(
            name: "NimbusGoogleKit",
            dependencies: ["NimbusTarget", .GoogleMobileAds]),
        .target(
            name: "NimbusLiveRampKit",
            dependencies: ["NimbusRequestTarget", .LiveRamp]),
        .target(
            name: "NimbusRequestAPSKit",
            dependencies: ["NimbusRequestTarget"]),
        .target(
            name: "NimbusUnityKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget"]),
        .target(
            name: "NimbusMintegralKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .Mintegral]),
        .target(
            name: "NimbusMobileFuseKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", "MobileFuseSDK"]),
        .target(
            name: "NimbusVungleKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .Vungle]),
        .binaryTarget(
            name: "MobileFuseSDK",
            url: "https://cdn.mobilefuse.com/sdk/1.8.2.zip",
            checksum: "f735bb81c18e163aea3c22c2d1aba2f4fe447a17c77ce3afe04d40c7480e621d"),
        .binaryTarget(
            name: "OMSDK_Adsbynimbus",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/omsdk/1.5.2/OMSDK_Adsbynimbus-1.5.2.zip",
            checksum: "f278a5a40efb856d028182e93a765b67c28b8ee3ff8b304d3e3d4bd882255442"),
        .binaryTarget(
             name: "DTBiOSSDK",
             url: "https://mdtb-sdk-packages.s3.us-west-2.amazonaws.com/iOS_APS_SDK/APS_iOS_SDK-4.9.7.zip",
             checksum: "99c5e84ffc914be96e842871302888182b457f87b7bb625c0c8157c4d2678907"),
        .binaryTarget(
            name: "FBAudienceNetwork",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/facebook/6.15.0/FBAudienceNetwork.zip",
            checksum: "b73dc30685aa03d626e7d53774baa5e4b8cd3467ddaeea8d94d96592e875aafc"),
        .binaryTarget(
            name: "UnityAds",
            url: "https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.12.2/UnityAds.zip",
            checksum: "897c70aae65ab340c2bff0038a933dee4611c2acd664e027245e23ac16e5c1fe"),
    ]
)

extension Target {
    static func framework(name: String, dependencies: [Target.Dependency]) -> Target {
        target(
            name: name,
            dependencies: dependencies,
            path: "Sources/\(name.replacingOccurrences(of: "Target", with: "Kit"))",
            sources: ["Export.swift"])
    }
}

extension Target.Dependency {
    static let LiveRamp = product(name: "LRAtsSDK", package: "ats-sdk-ios")
    static let MockingBird = product(name: "Mockingbird", package: "Mockingbird")
    static let Vungle = product(name: "VungleAdsSDK", package: "VungleAdsSDK-SwiftPackageManager")
    static let GoogleMobileAds = product(
        name: "GoogleMobileAds",
        package: "swift-package-manager-google-mobile-ads"
    )
    static let GoogleInteractiveMediaAds = product(
        name: "GoogleInteractiveMediaAds",
        package: "swift-package-manager-google-interactive-media-ads-ios"
    )
    static let Mintegral = product(
        name: "MintegralAdSDK",
        package: "MintegralAdSDK-Swift-Package"
    )
}

package.targets += [
    .binaryTarget(
        name: "NimbusCoreKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.25.5/NimbusCoreKit-2.25.5.zip",
        checksum: "bf4dea0468c425eea668f5ed66f9985514065e334991b2af8f2c43a29dfa8973"),
    .binaryTarget(
        name: "NimbusKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.25.5/NimbusKit-2.25.5.zip",
        checksum: "ecc3eb1bd47e06f33b56336e6bcd56d99ddc791c9c0fa9cfe7f77540e2c29b4f"),
    .binaryTarget(
        name: "NimbusRequestKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.25.5/NimbusRequestKit-2.25.5.zip",
        checksum: "e88fe9ba0468c296e8e659dec05ecd6d39c86ec70e11a55035f91d44124db355"),
    .binaryTarget(
        name: "NimbusRenderKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.25.5/NimbusRenderKit-2.25.5.zip",
        checksum: "037ecbfda16f79d1b345dad4cf6afe8c57c0501946a0a7f1c3b815d2b3b5107b"),
    .binaryTarget(
        name: "NimbusRenderStaticKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.25.5/NimbusRenderStaticKit-2.25.5.zip",
        checksum: "ba8c7b86b08c82745b1b9848db19b798ec331c3004cba780f8db882c10d0e565"),
    .binaryTarget(
        name: "NimbusRenderVideoKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.25.5/NimbusRenderVideoKit-2.25.5.zip",
        checksum: "83e30061fbf5b38d98e8c29635600a16facce2d2575594c6ae21a58b4d041bab"),
    .binaryTarget(
        name: "NimbusRenderVASTKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.25.5/NimbusRenderVASTKit-2.25.5.zip",
        checksum: "38fe8f1c9cf47e0f529aa251b1295a137c1b43e6eb63c4f15c662f9cae360c63"),
]