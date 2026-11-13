// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "NimbusKit",
    platforms: [.iOS(.v15)],
)

package.products = [
    .library(
        name: "NimbusKit",
        targets: ["NimbusKit"]
    )
]
package.targets += [
  .binaryTarget(
    name: "NimbusKit",
    url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/3.1.0/NimbusKit-3.1.0.zip",
    checksum: "d46e05da3b9f020fa4941c83d6811320fcbf2c220c0beae4c8602595f516ed95"
  ),
]
