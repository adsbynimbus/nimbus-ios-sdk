//
//  NimbusRequest+APS.swift
//  NimbusRequestAPSKit
//
//  Created on 3/22/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import DTBiOSSDK

public extension NimbusRequest {
    
    func addAPSResponse(_ response: DTBAdResponse) {
        guard let targeting = response.customTargeting() else { return }
        
        let impressionObjectExists = impressions[safe: 0] != nil
        guard impressionObjectExists else {
            Nimbus.shared.logger.log("Unable to add APS response payload, request is malformed", level: .error)
            
            return
        }
        
        if impressions[0].extensions == nil {
            impressions[0].extensions = [:]
        }
        
        if impressions[0].extensions?["aps"] == nil {
            impressions[0].extensions?["aps"] = NimbusCodable([targeting])
        } else if let originalAPSArray =
                    impressions[0].extensions?["aps"]?.value as? [[String: String]] {
            var modifiedAPSArray = originalAPSArray
            modifiedAPSArray.append(targeting)
            impressions[0].extensions?["aps"] = NimbusCodable(modifiedAPSArray)
        }
    }
    
    func addAPSLoader(_ loader: DTBAdLoader) {
        if let existingInterceptor =
            interceptors?.first(where: {$0 is NimbusAPSOnRequestInterceptor  }) as? NimbusAPSOnRequestInterceptor {
            existingInterceptor.appendLoader(loader)
        } else {
            let apsInterceptor = NimbusAPSOnRequestInterceptor(adLoaders: [loader])
            if interceptors == nil {
                interceptors = [apsInterceptor]
            } else {
                interceptors?.append(apsInterceptor)
            }
        }
    }
}
