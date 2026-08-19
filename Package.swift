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
    url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/3.0.0-rc.4/NimbusKit-3.0.0-rc.4.zip",
    checksum: "9fe4b0b09be5e70de3b2b9a43502129a5a8b6d9696a03ac5a60f91abfd51477e"
  ),
]
