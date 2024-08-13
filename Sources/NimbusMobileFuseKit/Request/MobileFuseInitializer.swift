//
//  MobileFuseInitializer.swift
//  NimbusMobileFuseKit
//  Created on 8/5/24
//  Copyright © 2024 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import MobileFuseSDK
import NimbusCoreKit

class MobileFuseInitializer: NSObject {
    
    enum State {
        case notInitialized, initializing, initialized
    }
    
    static let shared = MobileFuseInitializer()
    
    private(set) var state: State {
        get {
            lock.lock()
            defer { lock.unlock() }
            return internalState
        }
        set {
            lock.lock()
            internalState = newValue
            lock.unlock()
        }
    }
    
    private var internalState: State = .notInitialized
    private let logger: NimbusCoreKit.Logger
    
    /// Used to ensure the state is thread safe
    private let lock = NSLock()
    
    private init(logger: NimbusCoreKit.Logger = Nimbus.shared.logger) {
        self.logger = logger
        super.init()
    }
    
    func initIfNeeded() {
        guard state == .notInitialized else { return }
        
        state = .initializing
        
        DispatchQueue.main.async {
            MobileFuse.initWithDelegate(self)
        }
    }
}

extension MobileFuseInitializer: IMFInitializationCallbackReceiver {
    func onInitSuccess(_ appId: String!, withPublisherId publisherId: String!) {
        logger.log("Successfully initialized MobileFuse", level: .debug)
        state = .initialized
    }
    
    func onInitError(
        _ appId: String!,
        withPublisherId publisherId: String!,
        withError error: MFAdError!
    ) {
        logger.log("Failed initializing MobileFuse with appId=\(String(describing: appId)), publisherId=\(String(describing: publisherId)), error: \(error.description)", level: .error)
        state = .notInitialized
    }
}
