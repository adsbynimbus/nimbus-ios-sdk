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
    url: "https://adsbynimbus-public.s3.amazonaws.com/iOS/sdks/3.0.0-rc.5/NimbusKit-3.0.0-rc.5.zip",
    checksum: "ec95bd14170251d4ee306d80d1a08741f4e2c1b5f3c859cb34f1614ce305cd5d"
  ),
]
