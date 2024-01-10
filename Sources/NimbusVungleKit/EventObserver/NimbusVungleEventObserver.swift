//
//  NimbusVungleEventObserver.swift
//  NimbusVungleKit
//
//  Created on 18/05/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation

/// :nodoc:
@available(*, deprecated, message: "This protocol is no longer used and conforming to it will have no effect.")
public protocol NimbusVungleInitDelegate: AnyObject {
    func didInitialize()
    func didFailToInitializeWithError(_ error: Error)
}

/// :nodoc:
@available(*, deprecated, message: "This protocol is no longer used and conforming to it will have no effect.")
public protocol NimbusVungleEventObserverDelegate {
    func adPlayabilityUpdate(_ isAdPlayable: Bool, placementID: String?, markup: String?, error: Error?)
    func adViewed(for placementID: String?, markup: String?)
    func trackClick(for placementID: String?, markup: String?)
    func didCloseAd(for placementID: String?, markup: String?)
    func rewardUser(for placementID: String?, markup: String?)
}

/// :nodoc:
@available(*, deprecated, message: "This protocol is no longer used and conforming to it will have no effect.")
public protocol NimbusVungleEventObserverType {
    func addInitDelegate(delegate: NimbusVungleInitDelegate)
    func removeInitDelegate(delegate: NimbusVungleInitDelegate)

    func addDelegate(placementId: String, delegate: NimbusVungleEventObserverDelegate)
    func removeDelegate(placementId: String, delegate: NimbusVungleEventObserverDelegate)
}

/// :nodoc:
@available(*, deprecated, message: "This class is no longer used and inheriting it will have no effect.")
public final class NimbusVungleEventObserver: NSObject, NimbusVungleEventObserverType {
    
    public static var shared = NimbusVungleEventObserver()
    
    private override init() {
        super.init()
    }
    
    public func addInitDelegate(delegate: NimbusVungleInitDelegate) {}
    
    public func removeInitDelegate(delegate: NimbusVungleInitDelegate) {}
    
    public func addDelegate(placementId: String, delegate: NimbusVungleEventObserverDelegate) {}
    
    public func removeDelegate(placementId: String, delegate: NimbusVungleEventObserverDelegate) {}
}
