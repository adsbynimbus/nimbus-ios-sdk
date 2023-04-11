//
//  NimbusVungleEventObserverType.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 06/10/22.
//  Copyright © 2023 Timehop. All rights reserved.
//

#if SWIFT_PACKAGE
import ObjectiveC
#endif
import VungleSDK

public final class NimbusVungleEventObserver: NSObject, NimbusVungleEventObserverType, VungleSDKDelegate, VungleSDKHBDelegate {
    var initDelegates: [WeakReference<NimbusVungleInitDelegate>] = []
    
    public static var shared = NimbusVungleEventObserver()
    
    private let sdk = VungleSDK.shared()
    private(set) var delegates: [String: WeakReference<NimbusVungleEventObserverDelegate>] = [:]
    
    private override init() {
        super.init()
        sdk.delegate = self
        sdk.sdkHBDelegate = self
    }
    
    public func addInitDelegate(delegate: NimbusVungleInitDelegate) {
        initDelegates.append(WeakReference(value: delegate))
    }
    
    public func removeInitDelegate(delegate: NimbusVungleInitDelegate) {
        let identifier = ObjectIdentifier(delegate)
        if let index = initDelegates.firstIndex(where: { weakDelegate in
            if let del = weakDelegate.value {
                return ObjectIdentifier(del) == identifier
            }
            return false
        }) {
            initDelegates.remove(at: index)
        }
    }
    
    public func addDelegate(placementId: String, delegate: NimbusVungleEventObserverDelegate) {
        delegates[placementId] = WeakReference(value: delegate)
    }
    
    public func removeDelegate(placementId: String, delegate: NimbusVungleEventObserverDelegate) {
        delegates.removeValue(forKey: placementId)
    }
    
    public func vungleSDKDidInitialize() {
        initDelegates.forEach { $0.value?.didInitialize() }
    }
    
    public func vungleSDKFailedToInitializeWithError(_ error: Error) {
        initDelegates.forEach { $0.value?.didFailToInitializeWithError(error) }
    }
    
    public func vungleAdPlayabilityUpdate(_ isAdPlayable: Bool, placementID: String?, adMarkup: String?, error: Error?) {
        if let placementID {
            delegates[placementID]?.value?.adPlayabilityUpdate(isAdPlayable, placementID: placementID, markup: adMarkup, error: error)
        }
    }
    
    public func vungleAdViewed(forPlacementID placementID: String?, adMarkup: String?) {
        if let placementID {
            delegates[placementID]?.value?.adViewed(for: placementID, markup: adMarkup)
        }
    }
    
    public func vungleTrackClick(forPlacementID placementID: String?, adMarkup: String?) {
        if let placementID {
            delegates[placementID]?.value?.trackClick(for: placementID, markup: adMarkup)
        }
    }
    
    public func vungleDidCloseAd(forPlacementID placementID: String?, adMarkup: String?) {
        if let placementID {
            delegates[placementID]?.value?.didCloseAd(for: placementID, markup: adMarkup)
        }
    }
    
    public func vungleRewardUser(forPlacementID placementID: String?, adMarkup: String?) {
        if let placementID {
            delegates[placementID]?.value?.rewardUser(for: placementID, markup: adMarkup)
        }
    }
}
