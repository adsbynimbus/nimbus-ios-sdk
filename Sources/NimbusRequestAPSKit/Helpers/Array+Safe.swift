//
//  Array+Safe.swift
//  NimbusRequestAPSKit
//
//  Created by Inder Dhir on 1/8/20.
//  Copyright © 2020 Timehop. All rights reserved.
//

/// :nodoc:
extension Array {
    /// :nodoc:
    subscript (safe index: Int) -> Element? {
        return index >= 0 && index < self.count ? self[index] : nil
    }
}
