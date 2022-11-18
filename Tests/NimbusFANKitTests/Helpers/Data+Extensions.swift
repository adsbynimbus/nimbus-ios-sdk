//
//  Data+Extensions.swift
//  NimbusRequestingFANTests
//
//  Created by Inder Dhir on 5/24/19.
//  Copyright © 2019 Timehop. All rights reserved.
//

import Foundation

extension Data {
    func dict() throws -> [String: Any] {
        let dict = try JSONSerialization.jsonObject(with: self) as! [String: Any]
        return modify(dict)
    }

    private func modify(_ dict: [String: Any]) -> [String: Any] {
        var modifiedDict: [String: Any] = [:]
        for key in dict.keys {
            if let value = dict[key] as? [[String: Any]] {
                modifiedDict[key] = value.map { modify($0 )}
            } else if let value = dict[key] as? [String: Any] {
                modifiedDict[key] = modify(value)
            } else if let value = dict[key] as? String {
                modifiedDict[key] = value
            } else if let value = dict[key] as? [String] {
                modifiedDict[key] = value
            } else if let value = dict[key] as? Int {
                modifiedDict[key] = value
            } else if let value = dict[key] as? [Int] {
                modifiedDict[key] = value
            } else if let value = dict[key] as? Float {
                modifiedDict[key] = value
            } else if let value = dict[key] as? [Float] {
                modifiedDict[key] = value
            }
        }
        return modifiedDict
    }
}
