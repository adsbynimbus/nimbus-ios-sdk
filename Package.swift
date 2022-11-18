// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "NimbusSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "NimbusKit",
            targets: ["NimbusKit", "NimbusRenderKit", "NimbusRequestKit", "NimbusCoreKit"]),
        .library(
            name: "NimbusRenderKit",
            targets: ["NimbusRenderKit", "NimbusCoreKit"]),
        .library(
            name: "NimbusRenderStaticKit",
            targets: [
                "NimbusRenderKit",
                "NimbusRenderStaticKit",
                "NimbusCoreKit",
            ]),
        .library(
            name: "NimbusRenderVideoKit",
            targets: [
                "NimbusRenderKit",
                "NimbusRenderVideoKit",
                "NimbusCoreKit",
                "GoogleInteractiveMediaAds",
            ]),
        .library(
            name: "NimbusRequestKit",
            targets: ["NimbusRequestKit", "NimbusCoreKit"]),
        .library(
            name: "NimbusGAMKit",
            targets: ["NimbusGAMKit"]),
        .library(
            name: "NimbusFANKit",
            targets: ["NimbusFANKit"]),
        .library(
            name: "NimbusLiveRampKit",
            targets: ["NimbusLiveRampKit"]),
        .library(
            name: "NimbusRenderOMKit",
            targets: ["NimbusRenderOMKit", "OMSDKAdsbynimbus"]),
        .library(
            name: "NimbusRequestAPSKit",
            targets: ["NimbusRequestAPSKit"]),
        .library(
            name: "NimbusUnityKit",
            targets: ["NimbusUnityKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/faktorio/ats-sdk-ios-prod", from: "1.4.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", from: "9.12.0"),
    ],
    targets: [
        .target(
            name: "NimbusGAMKit",
            dependencies: [
                "NimbusKit",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")]),
        .testTarget(
            name: "NimbusGAMKitTests",
            dependencies: ["NimbusGAMKit"]),
        .target(
            name: "NimbusLiveRampKit",
            dependencies: [
                "NimbusRequestKit",
                .product(name: "LRAtsSDK", package: "ats-sdk-ios-prod")]),
        .testTarget(
            name: "NimbusLiveRampKitTests",
            dependencies: ["NimbusLiveRampKit"]),
        .target(
            name: "NimbusFANKit",
            dependencies: ["NimbusRenderKit", "NimbusRequestKit", "FBAudienceNetwork"]),
        .testTarget(
            name: "NimbusFANKitTests",
            dependencies: ["NimbusFANKit"]),
        .target(
            name: "NimbusRequestAPSKit",
            dependencies: ["NimbusRequestKit", "DTBiOSSDK"]),
        .testTarget(
            name: "NimbusRequestAPSKitTests",
            dependencies: ["NimbusRequestAPSKit"]),
        .target(
            name: "NimbusUnityKit",
            dependencies: ["NimbusRenderKit", "NimbusRequestKit", "UnityAds"]),
        .testTarget(
            name: "NimbusUnityKitTests",
            dependencies: ["NimbusUnityKit"]),
        .binaryTarget(
            name: "NimbusKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.1/NimbusKit-2.1.1.zip",
            checksum: "3e373f30c31a511d0905c6ca8eeefdda4aa5d0e9b15366bdd7203d90171ed46e"),
        .binaryTarget(
            name: "NimbusRequestKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.1/NimbusRequestKit-2.1.1.zip",
            checksum: "f6ad2a888e60ab1a7cfea68cf1dcb596494914545e87ef5cc2c93ed39a36367a"),
        .binaryTarget(
            name: "NimbusRenderKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.1/NimbusRenderKit-2.1.1.zip",
            checksum: "e685531f6986820ca87f7981d493790ce030ad6b1b1041e5f981fe6ea760c2e8"),
        .binaryTarget(
            name: "NimbusRenderStaticKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.1/NimbusRenderStaticKit-2.1.1.zip",
            checksum: "f392e455c22c5fa5c92d3c56ba330f79f2bfc21d88ec5d6ca1503ff90cba4c47"),
        .binaryTarget(
            name: "NimbusRenderVideoKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.1/NimbusRenderVideoKit-2.1.1.zip",
            checksum: "b4cbd6593e90f3b7cb4e11108657d207fa10a083b03531c51e0b4f2010fd0eec"),
        .binaryTarget(
            name: "NimbusRenderOMKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.1/NimbusRenderOMKit-2.1.1.zip",
            checksum: "449e74a0e51f0ad2fd3f798ade9bf64ac3ce122bf8c08ea59873cba2082427cc"),
        .binaryTarget(
            name: "NimbusCoreKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.1/NimbusCoreKit-2.1.1.zip",
            checksum: "cdded85aa86382c89dda4001c6f12588aaaba046c32856d5feb7fb034d66b128"),
        .binaryTarget(
            name: "GoogleInteractiveMediaAds",
            url: "https://imasdk.googleapis.com/native/downloads/ima-ios-v3.16.3.zip",
            checksum: "049bac92551b50247ea14dcbfde9aeb99ac2bea578a74f67c6f3e781d9aca101"),
        .binaryTarget(
            name: "OMSDKAdsbynimbus",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/omsdk/1.4.0/omsdk-adsbynimbus-1.4.0.zip",
            checksum: "736e996210bbd959fb563421b6328c4027b3349bc20772f3d7c83c4f426e3a94"),
        .binaryTarget(
            name: "DTBiOSSDK",
            url: "https://mdtb-sdk-packages.s3.us-west-2.amazonaws.com/iOS_APS_SDK/APS_iOS_SDK-4.5.5.zip",
            checksum: "0aaf4f92ace01441501f45a9d7fd4614d5e496ab925f6b84b4a1d96e9a65ba29"),
        .binaryTarget(
            name: "FBAudienceNetwork",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/facebook/6.12.0/FBAudienceNetwork.zip",
            checksum: "4bf37ee5949de007349d85b069da1095a30e82e696e72642dfe117aba08a86a2"
        ),
        .binaryTarget(
            name: "UnityAds",
            url: "https://github.com/Unity-Technologies/unity-ads-ios/releases/download/4.4.1/UnityAds.zip",
            checksum: "8196b13a0a5eae6ba817e2e7fc9096a584f22aedb1958980d2064955e448d5ad"),
    ]
)
