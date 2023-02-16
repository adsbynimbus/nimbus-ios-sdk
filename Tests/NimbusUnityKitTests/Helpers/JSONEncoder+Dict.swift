//
//  JSONEncoder+Dict.swift
//  NimbusRequestingFANTests
//
//  Created by Inder Dhir on 11/5/19.
//  Copyright © 2019 Timehop. All rights reserved.
//

import Foundation

extension Encodable {
    
    func jsonDict() -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(self)
            return try data.dict()
        } catch {
            return [:]
        }
    }
}
