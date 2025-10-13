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
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/omsdk/1.5.7/OMSDK_Adsbynimbus-1.5.7.zip",
            checksum: "6cbf70a0b8a807aaed1c467e13fc17b669fcaed9fe0163ec8077423bc4d9a7b0"),
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
            url: "https://moloco-ios-build.s3.amazonaws.com/moloco-sdk/MolocoSDK-3.11.0.zip",
            checksum: "2acae1deebf68644dc7c4cb8575ca670c54ef2469149f4f8eabf651e1d3a87c6"),
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
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.31.1/NimbusCoreKit-2.31.1.zip",
        checksum: "7f66274a6c1b90b55cf3c21e434e1fefb79ed7c7c5c3eed88ccd43d44fffac2e"),
    .binaryTarget(
        name: "NimbusKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.31.1/NimbusKit-2.31.1.zip",
        checksum: "fde623e96a586541565f81f516f58e70843df78ac9f7ba99faca796d39a3f3d3"),
    .binaryTarget(
        name: "NimbusRequestKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.31.1/NimbusRequestKit-2.31.1.zip",
        checksum: "0f840a4fa0acf918a244db9015fafe72b9d88b38d396411c1c3b064758e40723"),
    .binaryTarget(
        name: "NimbusRenderKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.31.1/NimbusRenderKit-2.31.1.zip",
        checksum: "a72381e923ac5751b790125846cf73498601113bce5cba46364475dc419028fd"),
    .binaryTarget(
        name: "NimbusRenderStaticKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.31.1/NimbusRenderStaticKit-2.31.1.zip",
        checksum: "b7c89d7cf735f0aeabe64b5a7b5299f4587304f5bef109ee5712d573fad4d39e"),
    .binaryTarget(
        name: "NimbusRenderVideoKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.31.1/NimbusRenderVideoKit-2.31.1.zip",
        checksum: "43430199ff22ea499aad446d2b83b05cf542cde8bf7f0a9958ce2490bab3936a"),
    .binaryTarget(
        name: "NimbusRenderVASTKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.31.1/NimbusRenderVASTKit-2.31.1.zip",
        checksum: "f30a3ee5f12a7e2d5531699097280a12f3f95cd0be2d4bbf35eae695b7b30ac1"),
]