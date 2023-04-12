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
           name: "NimbusRequestKit",
           targets: ["NimbusRequestTarget"]),
        .library(
           name: "NimbusGAMKit",
           type: .dynamic,
           targets: ["NimbusGAMKit"]),
        .library(
           name: "NimbusFANKit",
           type: .dynamic,
           targets: ["NimbusRenderFANKit", "NimbusRequestFANKit"]),
        .library(
           name: "NimbusLiveRampKit",
           targets: ["NimbusLiveRampKit"]),
        .library(
           name: "NimbusRequestAPSKit",
           type: .dynamic,
           targets: ["NimbusRequestAPSKit"]),
        .library(
           name: "NimbusUnityKit",
           type: .dynamic,
           targets: ["NimbusUnityKit"]),
        .library(
           name: "NimbusVungleKit",
           type: .dynamic,
           targets: ["NimbusVungleKit"]),
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
            dependencies: ["NimbusCoreKit", "NimbusRenderKit", "OMSDK_Adsbynimbus"]),
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
            dependencies: ["NimbusRenderTarget", "NimbusRenderVideoKit", "GoogleInteractiveMediaAds"]),
        .target(
            name: "NimbusRenderFANKit",
            dependencies: ["NimbusRenderTarget", "FBAudienceNetwork"]),
        .target(
            name: "NimbusRequestFANKit",
            dependencies: ["NimbusRequestTarget", "FBAudienceNetwork"]),
        .target(
            name: "NimbusGAMKit",
            dependencies: ["NimbusTarget", .GoogleMobileAds]),
        .target(
            name: "NimbusLiveRampKit",
            dependencies: [ "NimbusRequestTarget", .LiveRamp]),
        .target(
            name: "NimbusRequestAPSKit",
            dependencies: ["NimbusRequestTarget", "DTBiOSSDK"]),
        .target(
            name: "NimbusUnityKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", "UnityAds"]),
        .target(
            name: "NimbusVungleKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", "VungleSDK"]),
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
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.6.0/NimbusCoreKit-2.6.0.zip",
        checksum: "13015b6899d57a4edbdf4f7186cf23bc2b44a4f8a264fb7ddda2b29ad57be64d"),
    .binaryTarget(
        name: "NimbusKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.6.0/NimbusKit-2.6.0.zip",
        checksum: "2068484bedc77a782971b444201d8d4a022f02108026ba94ba9158839f2b8505"),
    .binaryTarget(
        name: "NimbusRenderKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.6.0/NimbusRenderKit-2.6.0.zip",
        checksum: "7a3e2dfffc5c15c8cca337243107256c7fa4d976bf57e0e53318258893188bdb"),
    .binaryTarget(
        name: "NimbusRenderStaticKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.6.0/NimbusRenderStaticKit-2.6.0.zip",
        checksum: "102dc393994e9cc5467a10e53a695020802f2eeda7a541df0f2d2ba14dcfbf61"),
    .binaryTarget(
        name: "NimbusRenderVideoKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.6.0/NimbusRenderVideoKit-2.6.0.zip",
        checksum: "57820d6c2f9b566e1d41b927a6e8d9dc2f2577058a081f1e2b0a7d988d45c6e3"),
    .binaryTarget(
        name: "NimbusRequestKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.6.0/NimbusRequestKit-2.6.0.zip",
        checksum: "a52678e0a209c14a5b589ce86f9c64decb669e1496a803e42cf676f904450a6e"),
]
