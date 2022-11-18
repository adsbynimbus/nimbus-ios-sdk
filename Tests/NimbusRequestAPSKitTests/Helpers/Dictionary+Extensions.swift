//
//  Dictionary+Extensions.swift
//  NimbusRequestingAPSTests
//
//  Created by Inder Dhir on 11/5/19.
//  Copyright © 2019 Timehop. All rights reserved.
//

import NimbusRequestKit

extension Dictionary where Value: Any {
    func isEqual(to otherDict: [Key: Any]) -> Bool {
        guard count == otherDict.count else {
            return false
        }

        for (k1, v1) in self {
            guard let v2 = otherDict[k1] else {
                return false
            }

            switch (v1, v2) {
            case (let v1 as String, let v2 as String):
                if v1 != v2 {
                    return false
                }
            case (let v1 as [String], let v2 as [String]):
                if v1.sorted() != v2.sorted() {
                    return false
                }
            case (let v1 as Int, let v2 as Int): if v1 != v2 {
                return false
                }
            case (let v1 as [Int], let v2 as [Int]): if v1.sorted() != v2.sorted() {
                return false
                }
            case (let v1 as Float, let v2 as Float):
                if !v1.isEqual(to: v2) {
                    return false
                }
            case (let v1 as [Key: Any], let v2 as [Key: Any]):
                if !v1.isEqual(to: v2) {
                    return false
                }
            case (let v1 as [[Key: Any]], let v2 as [[Key: Any]]):
                guard v1.count == v2.count else {
                    return false
                    
                }
                for dict1 in v1 {
                    guard v2.contains(where: { $0.isEqual(to: dict1) }) else {
                        return false
                    }
                }
            default:
                return false
            }
        }
        return true
    }
}
