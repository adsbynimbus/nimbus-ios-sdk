//
//  NimbusAdMobAdRequestor.swift
//  Nimbus
//
//  Created by Inder Dhir on 7/31/23.
//  Copyright © 2023 Timehop. All rights reserved.
//

import Foundation
import GoogleMobileAds
@_exported import NimbusKit

final class Weak<T: AnyObject & Hashable>: Hashable {
    let id = UUID()
    weak var value : T?
    
    init(_ value: T) {
        self.value = value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        if let value {
            hasher.combine(value)
        }
    }
    
    static func == (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
        lhs.id == rhs.id
    }
}

protocol NimbusAdMobRequestorType {
    func requestAd(
        request: NimbusRequest,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    )
}

final class NimbusAdMobAdRequestor: NimbusAdMobRequestorType {
    private let requestManager: NimbusRequestManager
    private let managedRequestsSerialQueue = DispatchQueue(label: "nimbus-admob-managed-requests")
    private typealias AdCompletion = (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    private var requestsInFlightDict: [Weak<NimbusRequest>: AdCompletion] = [:]
    
    init(requestManager: NimbusRequestManager) {
        self.requestManager = requestManager
        requestManager.delegate = self
    }
    
    func requestAd(
        request: NimbusRequest,
        completion: @escaping (Result<(NimbusAd, NimbusCompanionAd?), Error>) -> Void
    ) {
        managedRequestsSerialQueue.sync {
            requestsInFlightDict[Weak(request)] = completion
        }
        requestManager.performRequest(request: request)
    }
    
    private func getCompletionCallback(for request: NimbusRequest) -> AdCompletion? {
        managedRequestsSerialQueue.sync {
            guard let index = requestsInFlightDict.firstIndex(where: { $0.key.value == request }) else {
                return nil
            }
            return requestsInFlightDict.remove(at: index).value
        }
    }
    
    private func getCompanionAd(for request: NimbusRequest) -> NimbusCompanionAd? {
        if let firstCompanionAd = request.impressions[safe: 0]?.video?.companionAds?.first {
            return NimbusCompanionAd(
                width: firstCompanionAd.width,
                height: firstCompanionAd.height,
                renderMode: firstCompanionAd.companionAdRenderMode ?? .concurrent
            )
        }
        return nil
    }
}

// MARK: NimbusRequestManagerDelegate

extension NimbusAdMobAdRequestor: NimbusRequestManagerDelegate {
    func didCompleteNimbusRequest(request: NimbusRequestKit.NimbusRequest, ad: NimbusCoreKit.NimbusAd) {
        if let completion = getCompletionCallback(for: request) {
            let companionAd = getCompanionAd(for: request)
            completion(.success((ad, companionAd)))
        }
    }
    
    func didFailNimbusRequest(request: NimbusRequestKit.NimbusRequest, error: NimbusCoreKit.NimbusError) {
        if let completion = getCompletionCallback(for: request) {
            completion(.failure(error))
        }
    }
}

private extension Array {
    subscript (safe index: Int) -> Element? {
        index >= 0 && index < self.count ? self[index] : nil
    }
}
