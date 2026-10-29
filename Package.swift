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
    url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/3.0.0/NimbusKit-3.0.0.zip",
    checksum: "19be05dbcb60bee657b64d7189a6eebf6e90659247f53f9e5401063902b96205"
  ),
]
