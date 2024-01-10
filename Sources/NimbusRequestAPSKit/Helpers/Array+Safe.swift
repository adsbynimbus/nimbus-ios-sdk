//
//  Array+Safe.swift
//  NimbusRequestAPSKit
//
//  Created on 1/8/20.
//  Copyright © 2020 Nimbus Advertising Solutions Inc. All rights reserved.
//

/// :nodoc:
extension Array {
    /// :nodoc:
    subscript (safe index: Int) -> Element? {
        index >= 0 && index < self.count ? self[index] : nil
    }
}
