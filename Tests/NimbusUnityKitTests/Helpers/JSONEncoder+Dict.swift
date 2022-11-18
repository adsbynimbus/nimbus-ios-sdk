//
//  JSONEncoder+Dict.swift
//  NimbusRequestingFANTests
//
//  Created by Inder Dhir on 11/5/19.
//  Copyright © 2019 Timehop. All rights reserved.
//

import XCTest

extension Encodable {
    
    func jsonDict() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        do {
            return try data.dict()
        } catch {
            return [:]
        }
    }
}
