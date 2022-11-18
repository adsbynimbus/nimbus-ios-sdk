//
//  NimbusAPSRequestHelper.swift
//  NimbusRequestAPSKit
//
//  Created by Inder Dhir on 9/1/22.
//  Copyright © 2022 Timehop. All rights reserved.
//

import DTBiOSSDK
import Foundation
@_exported import NimbusRequestKit

/// Internal class, DO NOT USE
/// :nodoc:
public final class NimbusAPSRequestHelper {
    let requestManager: APSRequestManagerType
    var adSizes: [DTBAdSize] = []
    
    public init(
        appKey: String,
        requestManager: APSRequestManagerType? = nil,
        timeoutInSeconds: Double,
        enableTestMode: Bool = false
    ) {
        self.requestManager = requestManager ?? NimbusAPSRequestManager(
            appKey: appKey,
            logger: Nimbus.shared.logger,
            logLevel: Nimbus.shared.logLevel,
            timeoutInSeconds: timeoutInSeconds,
            enableTestMode: enableTestMode
        )
    }
    
    public func addAPSSlot(slotUUID: String, width: Int, height: Int, isVideo: Bool) {
        let adSize: DTBAdSize
        if isVideo {
            adSize = .init(videoAdSizeWithPlayerWidth: width, height: height, andSlotUUID: slotUUID)
        } else {
            let isInterstitialSize = (width == 320 && height == 480) || (width == 480 && height == 320)
            if isInterstitialSize {
                adSize = DTBAdSize(interstitialAdSizeWithSlotUUID: slotUUID)
            } else {
                adSize = DTBAdSize(bannerAdSizeWithWidth: width, height: height, andSlotUUID: slotUUID)
            }
        }
        
        adSizes.append(adSize)
    }
    
    public func fetchAPSParams(width: Int, height: Int, includeVideo: Bool) -> String? {
        let validAdSizes = adSizes.filter { adSize in
            let isVideo = adSize.adType.rawValue == 0
            if isVideo {
                return includeVideo
            }
            
            let isInterstitial = adSize.adType.rawValue == 2
            if isInterstitial {
                return (width == 320 && height == 480) || (width == 480 && height == 320)
            }

            return adSize.width == width && adSize.height == height
        }
        
        let apsPayload = requestManager.loadAdsSync(for: validAdSizes)
        return apsPayload.toJSONString()
    }
}

private extension Collection where Iterator.Element == [AnyHashable: Any] {
  func toJSONString() -> String {
    if let arr = self as? [[String: Any]],
       let dat = try? JSONSerialization.data(withJSONObject: arr),
       let str = String(data: dat, encoding: String.Encoding.utf8) {
      return str
    }
    return "[]"
  }
}
