// swift-tools-version: 5.6

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
            name: "NimbusFANKit",
            targets: ["NimbusFANKit", "FBAudienceNetwork"]),
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
            name: "NimbusRenderVideoKit-WithoutGoogleInteractiveMediaAds",
            targets: ["NimbusRenderVideoTarget"]),
        .library(
            name: "NimbusRequestAPSKit-WithoutDTBiOSSDK",
            targets: ["NimbusRequestAPSKit"]),
        .library(
            name: "NimbusFANKit-WithoutFBAudienceNetwork",
            targets: ["NimbusFANKit"]),
        .library(
            name: "NimbusUnityKit-WithoutUnityAds",
            targets: ["NimbusUnityKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/faktorio/ats-sdk-ios-prod", from: "1.4.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", from: "9.12.0"),
    ],
    targets: [
        .target(
            name: "NimbusRenderTarget",
            dependencies: ["NimbusRenderKit", "NimbusCoreKit", "OMSDK_Adsbynimbus"]),
        .target(
            name: "NimbusRenderStaticTarget",
            dependencies: ["NimbusRenderStaticKit", "NimbusRenderTarget"]),
        .target(
            name: "NimbusRenderVideoTarget",
            dependencies: ["NimbusRenderVideoKit", "NimbusRenderTarget"]),
        .target(
            name: "NimbusRequestTarget",
            dependencies: ["NimbusRequestKit", "NimbusCoreKit"]),
        .target(
            name: "NimbusTarget",
            dependencies: ["NimbusKit", "NimbusRequestTarget", "NimbusRenderTarget"]),
        .target(
            name: "NimbusGAMKit",
            dependencies: [
                "NimbusTarget",
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
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget"]),
        .testTarget(
            name: "NimbusFANKitTests",
            dependencies: ["NimbusFANKit", "FBAudienceNetwork"]),
        .target(
            name: "NimbusRequestAPSKit",
            dependencies: ["NimbusRequestTarget"]),
        .testTarget(
            name: "NimbusRequestAPSKitTests",
            dependencies: ["NimbusRequestAPSKit", "DTBiOSSDK"]),
        .target(
            name: "NimbusUnityKit",
            dependencies: ["NimbusRenderTarget", "NimbusRequestTarget"]),
        .testTarget(
            name: "NimbusUnityKitTests",
            dependencies: ["NimbusUnityKit", "UnityAds"]),
        .binaryTarget(
            name: "NimbusKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.4.1/NimbusKit-2.4.1.zip",
            checksum: "27db7850b35ae871ded3430be503ac6555a31b58eab75670552b525be7368949"),
        .binaryTarget(
            name: "NimbusRequestKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.4.1/NimbusRequestKit-2.4.1.zip",
            checksum: "78edbea655de6ca6eb1b12c06224095f54ccc8f29b166a27a9fa522b6e673750"),
        .binaryTarget(
            name: "NimbusRenderKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.4.1/NimbusRenderKit-2.4.1.zip",
            checksum: "00b877ba91d521fcb855f4a830102153ed28e5bee2cc08160e3cc24d523de70c"),
        .binaryTarget(
            name: "NimbusRenderStaticKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.4.1/NimbusRenderStaticKit-2.4.1.zip",
            checksum: "bf340e302256f99c6f5dd52243bca9d0a030748bcaab0733f9789970591b390f"),
        .binaryTarget(
            name: "NimbusRenderVideoKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.4.1/NimbusRenderVideoKit-2.4.1.zip",
            checksum: "24140b2623155cb0dbc48e2a3e35f94db38c8f4361c0357be788553b574a9421"),
        .binaryTarget(
            name: "NimbusCoreKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.4.1/NimbusCoreKit-2.4.1.zip",
            checksum: "2dcc6bc37a11cebadc736eb3d519e27db9c8c41a413ad7c4f77cdb21cd00316b"),
        .binaryTarget(
            name: "GoogleInteractiveMediaAds",
            url: "https://imasdk.googleapis.com/native/downloads/ima-ios-v3.16.3.zip",
            checksum: "049bac92551b50247ea14dcbfde9aeb99ac2bea578a74f67c6f3e781d9aca101"),
        .binaryTarget(
            name: "OMSDK_Adsbynimbus",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/external/omsdk/1.4.2/OMSDK_Adsbynimbus-1.4.2.zip",
            checksum: "c92acd23f1cec2c3418ae9f5b01c0dcc9aa4abaf3cfc7cd12de3aa4ed6c2b785"),
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
