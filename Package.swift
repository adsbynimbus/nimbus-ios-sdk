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
        .package(url: "https://github.com/LiveRamp/ats-sdk-ios.git", "1.4.0" ..< "3.0.0"),
        .package(url: "https://github.com/birdrides/mockingbird.git", from: "0.20.0"),
        .package(url: "https://github.com/Vungle/VungleAdsSDK-SwiftPackageManager.git", from: "7.4.0"),
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            "11.7.0"..<"13.0.0"
        ),
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
            url: "https://cdn.mobilefuse.com/sdk/1.7.6.zip",
            checksum: "0b4df7fa4b0923abe87b0fbff67c22c6f1157784fb841d7d288abaec3a94b850"),
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
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.24.2/NimbusCoreKit-2.24.2.zip",
        checksum: "46c578d79302b76f2f4f3174c1a65851205437f791dc57e20638549a4e3f73a6"),
    .binaryTarget(
        name: "NimbusKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.24.2/NimbusKit-2.24.2.zip",
        checksum: "4ac665ad28a5f333f9e28ddb64cdcc810996d94ee415ae388fce11bcb91f6da7"),
    .binaryTarget(
        name: "NimbusRequestKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.24.2/NimbusRequestKit-2.24.2.zip",
        checksum: "e6e867107fc8e75c7a599c134921a59571b7f6184669cca005fb7c06c2ed3bb3"),
    .binaryTarget(
        name: "NimbusRenderKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.24.2/NimbusRenderKit-2.24.2.zip",
        checksum: "75ca1efa164d1f76fceef3a15204271dffb612d918ef184c3d9a9e5c668d99ed"),
    .binaryTarget(
        name: "NimbusRenderStaticKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.24.2/NimbusRenderStaticKit-2.24.2.zip",
        checksum: "f6a85449776b0a11725155c58eac7899088b72a7acfe3405b6ebbaf8b566a15a"),
    .binaryTarget(
        name: "NimbusRenderVideoKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.24.2/NimbusRenderVideoKit-2.24.2.zip",
        checksum: "e2208c311e6c4a373b6e93fb412bf10b72e2f4eb4a72cd54b7b587b74a31b4bb"),
    .binaryTarget(
        name: "NimbusRenderVASTKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.24.2/NimbusRenderVASTKit-2.24.2.zip",
        checksum: "c832e45996214c2bc77d9b3dc9e235848162d85c9221bfcc5be8bdda5777ab37"),
]