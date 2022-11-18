//
//  JSONEncoder+Dict.swift
//  NimbusLiveRampKitTests
//
//  Created by Victor Takai on 01/08/22.
//  Copyright © 2022 Timehop. All rights reserved.
//

import Foundation

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
