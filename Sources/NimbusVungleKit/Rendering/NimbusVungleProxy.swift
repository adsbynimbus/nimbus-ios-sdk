//
//  NimbusVungleProxy.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 22/09/22.
//  Copyright © 2023 Timehop. All rights reserved.
//

import UIKit
import VungleSDK

/// Protocol used for loading and starting Vungle ads
protocol NimbusVungleProxyType {
    func loadPlacement(id: String, markup: String?) throws
    func loadPlacement(id: String, markup: String?, with size: VungleAdSize) throws
    func playAd(_ controller: UIViewController, options: [AnyHashable : Any]?, id: String?, markup: String?) throws
    func addAdView(to publisherView: UIView, options: [AnyHashable : Any]?, id: String?, markup: String?) throws
    func finishDisplayingAd(id: String, markup: String?)
}

/// Nimbus default wrapper for loading and starting Vungle ads
/// :nodoc:
final class NimbusVungleProxy: NSObject, NimbusVungleProxyType {
    
    private let sdk: VungleSDK = VungleSDK.shared()
    
    func loadPlacement(id: String, markup: String? = nil) throws {
        try sdk.loadPlacement(withID: id, adMarkup: markup)
    }
    
    func loadPlacement(id: String, markup: String? = nil, with size: VungleAdSize) throws {
        try sdk.loadPlacement(withID: id, adMarkup: markup, with: size)
    }
    
    func playAd(_ controller: UIViewController, options: [AnyHashable : Any]? = nil, id: String?, markup: String? = nil) throws {
        try sdk.playAd(controller, options: options, placementID: id, adMarkup: markup)
    }
    
    func addAdView(to publisherView: UIView, options: [AnyHashable : Any]? = nil, id: String?, markup: String? = nil) throws {
        try sdk.addAdView(to: publisherView, withOptions: options, placementID: id, adMarkup: markup)
    }
    
    func finishDisplayingAd(id: String, markup: String?) {
        sdk.finishDisplayingAd(id, adMarkup: markup)
    }
}
