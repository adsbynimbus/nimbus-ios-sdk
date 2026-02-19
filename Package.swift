// swift-tools-version: 5.6

import Foundation
import PackageDescription

let package = Package(
    name: "NimbusSDK",
    platforms: [.iOS(.v13)],
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
           name: "NimbusMolocoKit",
           targets: ["NimbusMolocoKit"]),
        .library(
           name: "NimbusInMobiKit",
           targets: ["NimbusInMobiKit"]),
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
        .package(url: "https://github.com/Vungle/VungleAdsSDK-SwiftPackageManager.git", from: "7.6.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "12.0.0"),
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
            dependencies: ["NimbusRenderTarget", "NimbusRenderVideoKit"]),
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
            name: "NimbusMolocoKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", "MolocoSDK"]),
        .target(
            name: "NimbusInMobiKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", "InMobiSDK"]),
        .target(
            name: "NimbusVungleKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .Vungle]),
        .binaryTarget(
            name: "MobileFuseSDK",
            url: "https://cdn.mobilefuse.com/sdk/1.9.3.zip",
            checksum: "cee2b9a134c8aa16e0312997ede0e4087fc9f24eabfaeaef2e54793285f52e9d"),
        .binaryTarget(
            name: "OMSDK_Adsbynimbus",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/omsdk/1.6.0/OMSDK_Adsbynimbus-1.6.0.zip",
            checksum: "ee15f532875ee4c2d2f8ab17117842becada706aaedd2448fa423ffc995086f3"),
        .binaryTarget(
             name: "DTBiOSSDK",
             url: "https://mdtb-sdk-packages.s3.us-west-2.amazonaws.com/iOS_APS_SDK/APS_iOS_SDK-5.2.0.zip",
             checksum: "296bfb7ef3c0f885efc737b776cd5587a4fc3773d753b696b20eb5945a5d2a6f"),
        .binaryTarget(
            name: "FBAudienceNetwork",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/facebook/6.20.1/FBAudienceNetwork.zip",
            checksum: "f8fae0d41b275fb97fce78038c6cd75eb066fc095e556e08195212dd5d7df7f9"),
        .binaryTarget(
            name: "UnityAds",
            url: "https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.15.1/UnityAds.zip",
            checksum: "14bf337196be779f91f894c6bc919b3394cf599a6c3a2e3da434773906b68a68"),
        .binaryTarget(
            name: "MolocoSDK",
            url: "https://moloco-ios-build.s3.amazonaws.com/moloco-sdk/MolocoSDK-3.13.1.zip",
            checksum: "7ac361b9b2e30eb82dfdd246440b0088c8e1d1e6dcc69f3362195b168cdbc9a0"),
        .binaryTarget(
            name: "InMobiSDK",
            url: "https://dl.inmobi.com/inmobi-sdk/IM/InMobi-iOS-SDK-10.8.6.zip",
            checksum: "ab0f05cd8aa0a7b1085a2b4f57f06ba27ae5dc310e1d9c1241011bba6ba98949")
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
    static let Mintegral = product(
        name: "MintegralAdSDK",
        package: "MintegralAdSDK-Swift-Package"
    )
}

package.targets += [
    .binaryTarget(
        name: "NimbusCoreKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.32.3/NimbusCoreKit-2.32.3.zip",
        checksum: "0a366fa687a0d24d9745b78ad03a52c10de7dacc1fa197988da68b881a0a3df4"),
    .binaryTarget(
        name: "NimbusKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.32.3/NimbusKit-2.32.3.zip",
        checksum: "5b33610df908d7c006fa0c7448084d459d332b79af398d065d448b1db5dcfc9a"),
    .binaryTarget(
        name: "NimbusRequestKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.32.3/NimbusRequestKit-2.32.3.zip",
        checksum: "ad342959cdf54e0f07ba8293a476f32169d62fa5fca9dc800d595b45f6eafd95"),
    .binaryTarget(
        name: "NimbusRenderKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.32.3/NimbusRenderKit-2.32.3.zip",
        checksum: "bc71a1878e4612886b69ddcc3a2c6654e7569415e30dac9c92d9f4b08597dd37"),
    .binaryTarget(
        name: "NimbusRenderStaticKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.32.3/NimbusRenderStaticKit-2.32.3.zip",
        checksum: "18679ed0d4835920d4f8f30269d5cf1d3c091e90b83c5597c528ddfcc208b928"),
    .binaryTarget(
        name: "NimbusRenderVideoKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.32.3/NimbusRenderVideoKit-2.32.3.zip",
        checksum: "6c1c38465a93f908c20d3b4a2f416dd6ef0222bf921a66b83a8aef7131fde0d9"),
]