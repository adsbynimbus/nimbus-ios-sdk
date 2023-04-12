//
//  WeakReference.swift
//  NimbusVungleKit
//
//  Created by Inder Dhir on 2/21/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

import Foundation

struct WeakReference<T> {
    private weak var storage: AnyObject?
    var value: T? {
        get { return storage.map { $0 as! T } }
        set { storage = newValue.map { $0 as AnyObject } }
    }
    
    init(value: T?) {
        self.value = value
    }
}
