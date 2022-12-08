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
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.2/NimbusKit-2.1.2.zip",
            checksum: "0ae72204b6fcf48433d4e00d95342bbc0dafbc98a3b3942453cc77e2f8ef3e5b"),
        .binaryTarget(
            name: "NimbusRequestKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.2/NimbusRequestKit-2.1.2.zip",
            checksum: "d4d7f53a721ff9a43a6d2c67c894a502ea63eb9cc57d8284843742210ee7b331"),
        .binaryTarget(
            name: "NimbusRenderKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.2/NimbusRenderKit-2.1.2.zip",
            checksum: "2b58b9a2f2c972896d66611e229709a5fdcc08490595014d996af7e61e70cafc"),
        .binaryTarget(
            name: "NimbusRenderStaticKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.2/NimbusRenderStaticKit-2.1.2.zip",
            checksum: "a96f96f1c47012f2f0def93d9532de87407d48155df967e6f2cf3b43f1170462"),
        .binaryTarget(
            name: "NimbusRenderVideoKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.2/NimbusRenderVideoKit-2.1.2.zip",
            checksum: "4747ddbb4632bf425b4d3282edd72d5f01111c611a95a781090bf99d3f0efafa"),
        .binaryTarget(
            name: "NimbusRenderOMKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.2/NimbusRenderOMKit-2.1.2.zip",
            checksum: "ca0c2eccafabbee1123d69bd6511213267cbd4b8be9822407e1d04e408d7db9f"),
        .binaryTarget(
            name: "NimbusCoreKit",
            url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/2.1.2/NimbusCoreKit-2.1.2.zip",
            checksum: "6f631fd8dfe5ca38e04629def85660724224ff6b6ff390f93cdd88df0d19e547"),
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
