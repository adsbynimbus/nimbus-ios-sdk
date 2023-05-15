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
           targets: ["NimbusRenderTarget", "OMSDK_Adsbynimbus"]),
        .library(
           name: "NimbusRenderStaticKit",
           targets: ["NimbusRenderStaticTarget"]),
        .library(
           name: "NimbusRenderVideoKit",
           targets: ["NimbusRenderVideoTarget", "GoogleInteractiveMediaAds"]),
        .library(
           name: "NimbusRequestKit",
           targets: ["NimbusRequestTarget"]),
        .library(
           name: "NimbusGAMKit",
           targets: ["NimbusGAMKit"]),
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
           targets: ["NimbusVungleKit", "VungleSDK"]),
        .library(
           name: "NimbusRenderVideoKit-WithoutGoogleInteractiveMediaAds",
           targets: ["NimbusRenderVideoTarget"]),
        .library(
           name: "NimbusRequestAPSKit-WithoutDTBiOSSDK",
           targets: ["NimbusRequestAPSKit"]),
        .library(
           name: "NimbusFANKit-WithoutFBAudienceNetwork",
           targets: ["NimbusRenderFANKit", "NimbusRequestFANKit"]),
        .library(
           name: "NimbusUnityKit-WithoutUnityAds",
           targets: ["NimbusUnityKit"]),
        .library(
           name: "NimbusVungleKit-WithoutVungleSDK",
           targets: ["NimbusVungleKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/LiveRamp/ats-sdk-ios.git", from: "1.4.0"),
        .package(url: "https://github.com/birdrides/mockingbird.git", from: "0.20.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", "9.12.0"..<"11.0.0"),
    ],
    targets: [
        .framework(
            name: "NimbusRenderTarget",
            dependencies: ["NimbusCoreKit", "NimbusRenderKit"]),
        .framework(
            name: "NimbusRequestTarget",
            dependencies: ["NimbusCoreKit", "NimbusRequestKit"]),
        .framework(
            name: "NimbusTarget",
            dependencies: ["NimbusRequestTarget", "NimbusRenderTarget", "NimbusKit"]),
        .framework(
            name: "NimbusRenderStaticTarget",
            dependencies: ["NimbusRenderTarget", "NimbusRenderStaticKit"]),
        .framework(
            name: "NimbusRenderVideoTarget",
            dependencies: ["NimbusRenderTarget", "NimbusRenderVideoKit"]),
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
            name: "NimbusLiveRampKit",
            dependencies: [ "NimbusRequestTarget", .LiveRamp]),
        .target(
            name: "NimbusRequestAPSKit",
            dependencies: ["NimbusRequestTarget"]),
        .target(
            name: "NimbusUnityKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget"]),
        .target(
            name: "NimbusVungleKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget"]),
        .binaryTarget(
            name: "GoogleInteractiveMediaAds",
            url: "https://imasdk.googleapis.com/native/downloads/ima-ios-v3.16.3.zip",
            checksum: "049bac92551b50247ea14dcbfde9aeb99ac2bea578a74f67c6f3e781d9aca101"),
        .binaryTarget(
            name: "OMSDK_Adsbynimbus",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/omsdk/1.4.2/omsdk-adsbynimbus-1.4.2.zip",
            checksum: "d42443a5d19a34418976945d8afcd11f25d471fa3178f80eba1c3f6035c0ad24"),
        .binaryTarget(
            name: "DTBiOSSDK",
            url: "https://mdtb-sdk-packages.s3.us-west-2.amazonaws.com/iOS_APS_SDK/APS_iOS_SDK-4.5.5.zip",
            checksum: "0aaf4f92ace01441501f45a9d7fd4614d5e496ab925f6b84b4a1d96e9a65ba29"),
        .binaryTarget(
            name: "FBAudienceNetwork",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/facebook/6.12.0/FBAudienceNetwork.zip",
            checksum: "4bf37ee5949de007349d85b069da1095a30e82e696e72642dfe117aba08a86a2"),
        .binaryTarget(
            name: "UnityAds",
            url: "https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.4.1/UnityAds.zip",
            checksum: "8196b13a0a5eae6ba817e2e7fc9096a584f22aedb1958980d2064955e448d5ad"),
        .binaryTarget(
            name: "VungleSDK",
            url: "https://vungle2-sdk-dev-scratch.s3.amazonaws.com/ios/6.12.x/vungle6123.zip",
            checksum: "1fe502a94d7ea03a750f0e5a5922610ebceb93b862f6d9e1baca4c43c5f3cad1"),
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
    static let GoogleMobileAds = product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
    static let LiveRamp = product(name: "LRAtsSDK", package: "ats-sdk-ios")
    static let MockingBird = product(name: "Mockingbird", package: "Mockingbird")
}

package.targets += [
    .binaryTarget(
        name: "NimbusCoreKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.8.1/NimbusCoreKit-2.8.1.zip",
        checksum: "3ba2c49c3b39ad1b58c96996d8c9336f48d2b221d40b300c8b799b1a15437ceb"),
    .binaryTarget(
        name: "NimbusKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.8.1/NimbusKit-2.8.1.zip",
        checksum: "55ce476aa0b9dac39b1026fa77e7dafb6432ad59e8750ea9457f073aff51cddb"),
    .binaryTarget(
        name: "NimbusRenderKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.8.1/NimbusRenderKit-2.8.1.zip",
        checksum: "9c8b95b6cf75aa9e796f613b1dbc6d5bcd3456dbaee4d1ec7c542400e73a824d"),
    .binaryTarget(
        name: "NimbusRenderStaticKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.8.1/NimbusRenderStaticKit-2.8.1.zip",
        checksum: "2fbbc45e1d7cc16d5c28cf1ed1dbd3195b0761c387c25f273e267f20052a447a"),
    .binaryTarget(
        name: "NimbusRenderVideoKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.8.1/NimbusRenderVideoKit-2.8.1.zip",
        checksum: "562946fb79831648de6aba2e12f56fcdf89d22059423ac83564d25b0cf5368d4"),
    .binaryTarget(
        name: "NimbusRequestKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.8.1/NimbusRequestKit-2.8.1.zip",
        checksum: "da3e3ceaed2aae3bdcc2133f3fd11acd526ad774fe835058c364c78de5f3e0b5"),
]