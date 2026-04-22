// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "NimbusKit",
    platforms: [.iOS(.v13)],
    targets: [
        .binaryTarget(
            name: "OMSDK-Adsbynimbus",
            url: "https://adsbynimbus-public.s3.us-east-1.amazonaws.com/iOS/external/omsdk/1.6.5/OMSDK_Adsbynimbus-1.6.5.zip",
            checksum: "0948cf0e1d68d53904d7f8c96703457496adc1b0d8f10782d59409b0f7a6e974"
        )
    ]
)

package.products = [
    .library(
        name: "NimbusKit",
        targets: ["NimbusTarget"]
    )
]

package.targets += [
    .target(
        name: "NimbusTarget",
        dependencies: ["OMSDK-Adsbynimbus", "NimbusKit"],
        path: "Sources/NimbusKit"
    )
]
package.targets += [
  .binaryTarget(
    name: "NimbusKit",
    url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/3.0.0-rc.1/NimbusKit-3.0.0-rc.1.zip",
    checksum: "ba81d3bdb2cf670fa8107822337889ca8f7cc3e734c68a6484ce80587e2cf06b"
  ),
]
