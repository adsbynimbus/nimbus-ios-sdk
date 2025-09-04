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
           name: "NimbusMolocoKit",
           targets: ["NimbusMolocoKit"]),
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
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "12.0.0"),
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
                "NimbusRenderVASTTarget",
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
            name: "NimbusVungleKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .Vungle]),
        .binaryTarget(
            name: "MobileFuseSDK",
            url: "https://cdn.mobilefuse.com/sdk/1.9.3.zip",
            checksum: "cee2b9a134c8aa16e0312997ede0e4087fc9f24eabfaeaef2e54793285f52e9d"),
        .binaryTarget(
            name: "OMSDK_Adsbynimbus",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/omsdk/1.5.5/OMSDK_Adsbynimbus-1.5.5.zip",
            checksum: "75ee4a33af8b5368f44f85467a6ae7069940ec9f02fdc56142b5f8372f4f7bbc"),
        .binaryTarget(
             name: "DTBiOSSDK",
             url: "https://mdtb-sdk-packages.s3.us-west-2.amazonaws.com/iOS_APS_SDK/APS_iOS_SDK-5.2.0.zip",
             checksum: "296bfb7ef3c0f885efc737b776cd5587a4fc3773d753b696b20eb5945a5d2a6f"),
        .binaryTarget(
            name: "FBAudienceNetwork",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/facebook/6.20.0/FBAudienceNetwork.zip",
            checksum: "7bcf514770f106538d75072a06117ef4f96ac033acb644220e0c7818acd0f45d"),
        .binaryTarget(
            name: "UnityAds",
            url: "https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.15.1/UnityAds.zip",
            checksum: "14bf337196be779f91f894c6bc919b3394cf599a6c3a2e3da434773906b68a68"),
        .binaryTarget(
            name: "MolocoSDK",
            url: "https://moloco-ios-build.s3.amazonaws.com/moloco-sdk/MolocoSDK-3.11.0.zip",
            checksum: "2acae1deebf68644dc7c4cb8575ca670c54ef2469149f4f8eabf651e1d3a87c6")
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
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.29.4/NimbusCoreKit-2.29.4.zip",
        checksum: "92abb2bb30d6bcd78c2c94d33d28b72de0ea76b329677c6d20606986246297df"),
    .binaryTarget(
        name: "NimbusKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.29.4/NimbusKit-2.29.4.zip",
        checksum: "5450a446149cee8b8679b2b368964ca724d351453a603c02702a913548d1f9c0"),
    .binaryTarget(
        name: "NimbusRequestKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.29.4/NimbusRequestKit-2.29.4.zip",
        checksum: "5c8b8f44172b57be26783f9af2b17604489bc50e323db50fd9d9c3fd2250ca9a"),
    .binaryTarget(
        name: "NimbusRenderKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.29.4/NimbusRenderKit-2.29.4.zip",
        checksum: "8cf83e7b6d11746265b9f5f9462caa5ef2e05e19eaed214c5194a54358078676"),
    .binaryTarget(
        name: "NimbusRenderStaticKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.29.4/NimbusRenderStaticKit-2.29.4.zip",
        checksum: "5a1b8a2a50300fe0b31a304c29cac7f876d1e6a188fa45b9943dd4fb93870b44"),
    .binaryTarget(
        name: "NimbusRenderVideoKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.29.4/NimbusRenderVideoKit-2.29.4.zip",
        checksum: "7cbd4421cd8663b05c6a2c8523a7b10059a4c1c5998c41918c43d5af57d74b43"),
    .binaryTarget(
        name: "NimbusRenderVASTKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.29.4/NimbusRenderVASTKit-2.29.4.zip",
        checksum: "a48432fcb07f53182bedf21251eba85172f83f9cc7274514f82955f942f0c3ef"),
]