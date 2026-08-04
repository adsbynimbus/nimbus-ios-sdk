// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "NimbusKit",
    platforms: [.iOS(.v13)],
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
    url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/3.0.0-rc.3/NimbusKit-3.0.0-rc.3.zip",
    checksum: "97d1874838f9279d45858dac7b7975135f04b474ccf3435ee49d09cf953c9c96"
  ),
]
