# Nimbus iOS SDK

Welcome to Nimbus - ads by publishers, for publishers.

## Requirements

- Xcode 26.6 or above
- iOS 15+

## Installation

### Xcode Project

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL:
   ```
   https://github.com/adsbynimbus/nimbus-ios-sdk
   ```
3. Set the dependency rule to **Up to Next Major Version** and enter `3.0.0` as the minimum.
4. Click **Add Package** and select the **NimbusKit** library when prompted.

### Package.swift

If you're managing dependencies through a `Package.swift` file, add the following:

```swift
dependencies: [
    .package(url: "https://github.com/adsbynimbus/nimbus-ios-sdk", from: "3.0.0")
]
```

Then add the product to your target:

```swift
.product(name: "NimbusKit", package: "nimbus-ios-sdk")
```

## Documentation

- [Nimbus iOS SDK Documentation](https://docs.adsbynimbus.com/docs) — integration guides, configuration, and API reference.
- [DocC API Reference](https://iosdocs.adsbynimbus.com) — auto-generated documentation for the latest release.

## Sample App

See Nimbus in action in our public [sample app repository](https://github.com/adsbynimbus/nimbus-ios-sample), which demonstrates end-to-end integration including setup, bid requests, and ad rendering.