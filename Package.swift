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
           targets: ["NimbusRenderVideoTarget", "GoogleInteractiveMediaAds"]),
        .library(
           name: "NimbusRequestKit",
           targets: ["NimbusRequestTarget"]),
        .library(
           name: "NimbusGAMKit",
           targets: ["NimbusGAMKit"]),
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
    ],
    dependencies: [
        .package(url: "https://github.com/LiveRamp/ats-sdk-ios.git", "1.4.0" ..< "3.0.0"),
        .package(url: "https://github.com/birdrides/mockingbird.git", from: "0.20.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", "9.12.0"..<"11.0.0"),
        .package(url: "https://github.com/Vungle/VungleAdsSDK-SwiftPackageManager.git", from: "7.0.0"),
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
            dependencies: ["NimbusRenderTarget", "NimbusRenderVideoKit", "GoogleInteractiveMediaAds"]),
        .framework(
            name: "NimbusMobileFuseTarget",
            dependencies: ["NimbusRequestTarget", "NimbusRenderTarget", "NimbusMobileFuseKit", "MobileFuseSDK"]),
        .framework(
            name: "NimbusTarget",
            dependencies: [
                "NimbusRequestTarget",
                "NimbusRenderTarget",
                "NimbusRenderStaticTarget",
                "NimbusRenderVideoTarget",
                "NimbusMobileFuseTarget",
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
            name: "NimbusVungleKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget", .Vungle]),
        .binaryTarget(
            name: "MobileFuseSDK",
            url: "https://cdn.mobilefuse.com/sdk/1.6.5.zip",
            checksum: "e1d739c54ee9d3ef79ca1e78cb2bf57880a07513ea4e418280954953c31b0b35"),
        .binaryTarget(
            name: "GoogleInteractiveMediaAds",
            url: "https://imasdk.googleapis.com/native/downloads/ima-ios-v3.16.3.zip",
            checksum: "049bac92551b50247ea14dcbfde9aeb99ac2bea578a74f67c6f3e781d9aca101"),
        .binaryTarget(
            name: "OMSDK_Adsbynimbus",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/omsdk/1.4.7/omsdk-adsbynimbus-1.4.7.zip",
            checksum: "dcafb165d68d544aeb1ae6c661d401eea0512ed11460ac69c58b91e2c14e9145"),
        .binaryTarget(
            name: "DTBiOSSDK",
            url: "https://mdtb-sdk-packages.s3.us-west-2.amazonaws.com/iOS_APS_SDK/APS_iOS_SDK-4.5.6.zip",
            checksum: "773a87ffc8c47141540048c657c926122c7e475ca8f8852ea95c8bcf775b14ab"),
        .binaryTarget(
            name: "FBAudienceNetwork",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/facebook/6.12.0/FBAudienceNetwork.zip",
            checksum: "4bf37ee5949de007349d85b069da1095a30e82e696e72642dfe117aba08a86a2"),
        .binaryTarget(
            name: "UnityAds",
            url: "https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.4.1/UnityAds.zip",
            checksum: "8196b13a0a5eae6ba817e2e7fc9096a584f22aedb1958980d2064955e448d5ad"),
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
    static let Vungle = product(name: "VungleAdsSDK", package: "VungleAdsSDK-SwiftPackageManager")
}

package.targets += [
    .binaryTarget(
        name: "NimbusCoreKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.17.1/NimbusCoreKit-2.17.1.zip",
        checksum: "90a0acd5083f3824a703e62e4b29c4795be2ba91c95e013c96706ae878870a90"),
    .binaryTarget(
        name: "NimbusKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.17.1/NimbusKit-2.17.1.zip",
        checksum: "48908c7efd0c0db1e01b362e58e3795a806e9da522d421c267b44053f931a039"),
    .binaryTarget(
        name: "NimbusMobileFuseKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.17.1/NimbusMobileFuseKit-2.17.1.zip",
        checksum: "2b28f9487487a9e80af80b550f2cb94e43b305e74e74151b315061cd7a1d965f"),
    .binaryTarget(
        name: "NimbusRenderKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.17.1/NimbusRenderKit-2.17.1.zip",
        checksum: "1b1ef4218118607982420f714bf1e91a84ea92f145a6075ee9b64336192424f7"),
    .binaryTarget(
        name: "NimbusRenderStaticKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.17.1/NimbusRenderStaticKit-2.17.1.zip",
        checksum: "7e5f8e1ea89293497a31be3b3527dcbc58dcdedbc4219b5950079c64bc1b874b"),
    .binaryTarget(
        name: "NimbusRenderVideoKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.17.1/NimbusRenderVideoKit-2.17.1.zip",
        checksum: "34843817c0a56fec35a043e604fefa89c0b87b926e8d256d86b6dab9329c3dcc"),
    .binaryTarget(
        name: "NimbusRequestKit",
        url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.17.1/NimbusRequestKit-2.17.1.zip",
        checksum: "047cd0d7a1666cc46b44251af6ad1c966aabe0d8d242998bbd8a0c18bd0e72d5"),
]