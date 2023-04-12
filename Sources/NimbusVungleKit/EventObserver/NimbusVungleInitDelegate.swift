//
//  NimbusVungleInitDelegate.swift
//  NimbusVungleKit
//
//  Created by Inder Dhir on 2/22/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

public protocol NimbusVungleInitDelegate: AnyObject {
    func didInitialize()
    func didFailToInitializeWithError(_ error: Error)
}
