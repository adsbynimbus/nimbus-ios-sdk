//
//  NimbusVungleEventObserver.swift
//  NimbusVungleKit
//
//  Created by Inder Dhir on 2/16/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

public protocol NimbusVungleEventObserverDelegate {
    func adPlayabilityUpdate(_ isAdPlayable: Bool, placementID: String?, markup: String?, error: Error?)
    func adViewed(for placementID: String?, markup: String?)
    func trackClick(for placementID: String?, markup: String?)
    func didCloseAd(for placementID: String?, markup: String?)
    func rewardUser(for placementID: String?, markup: String?)
}

public protocol NimbusVungleEventObserverType {
    func addInitDelegate(delegate: NimbusVungleInitDelegate)
    func removeInitDelegate(delegate: NimbusVungleInitDelegate)

    func addDelegate(placementId: String, delegate: NimbusVungleEventObserverDelegate)
    func removeDelegate(placementId: String, delegate: NimbusVungleEventObserverDelegate)
}
