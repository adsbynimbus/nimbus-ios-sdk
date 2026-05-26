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
    url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/3.0.0-rc.2/NimbusKit-3.0.0-rc.2.zip",
    checksum: "5d45cbab3be9d62e7ca76e9359319904d1c7e4898b3d0e11ed7a2089869e6c4a"
  ),
]
