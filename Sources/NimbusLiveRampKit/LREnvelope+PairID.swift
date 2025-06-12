//
//  LREnvelope+PairID.swift
//  Nimbus
//  Created on 3/17/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import LRAtsSDK

extension LREnvelope {
    // This helper decodes Pair IDs from LiveRamp envelope
    var pairIds: [String]? {
        guard let envelope25, let decodedPair = Data(base64Encoded: envelope25),
              let pairIds = try? JSONSerialization.jsonObject(with: decodedPair) as? [String]
        else { return nil }
        
        return pairIds
    }
}
