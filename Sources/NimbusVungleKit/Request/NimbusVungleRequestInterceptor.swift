//
//  NimbusVungleRequestInterceptor.swift
//  NimbusVungleKit
//
//  Created by Victor Takai on 12/09/22.
//  Copyright © 2023 Timehop. All rights reserved.
//

@_exported import NimbusRequestKit
import VungleSDK

public protocol NimbusVungleRequestInterceptorDelegate: AnyObject {
    func didInitializeVungle(with error: Error?)
}

/// Enables Vungle demand for NimbusRequest
/// Add an instance of this to `NimbusAdManager.requestInterceptors`
public final class NimbusVungleRequestInterceptor {
    
    /// Vungle app id
    private let appId: String
    
    /// Vungle request protocol
    private var vungleRequestType: NimbusVungleRequestType
    
    /// Vungle event observer protocol
    private var vungleEventObserverType: NimbusVungleEventObserverType?
    
    /// Delegate for listening Vungle callbacks
    public weak var delegate: NimbusVungleRequestInterceptorDelegate?
    
    /**
     Initializes a NimbusVungleRequestInterceptor instance
     
     - Parameters:
     - appId: Vungle app id
     - isLoggingEnabled: Toggles Vungle logger
     - vungleRequestType: Vungle request wrapper, use the default object
     - vungleEventObserverType: Vungle event observer, use the default object
     - delegate: Object that conforms to NimbusVungleRequestInterceptorDelegate
     */
    public init(
        appId: String,
        isLoggingEnabled: Bool = false,
        vungleRequestType: NimbusVungleRequestType = NimbusVungleRequest(),
        vungleEventObserverType: NimbusVungleEventObserverType = NimbusVungleEventObserver.shared,
        delegate: NimbusVungleRequestInterceptorDelegate? = nil
    ) {
        self.appId = appId
        
        self.vungleRequestType = vungleRequestType
        self.vungleRequestType.setLoggingEnabled(isLoggingEnabled)
        
        self.vungleEventObserverType = vungleEventObserverType
        self.delegate = delegate
        
        self.vungleEventObserverType?.addInitDelegate(delegate: self)
        
        if self.vungleRequestType.isInitialized {
            Nimbus.shared.logger.log("Vungle provider has been already initialized", level: .info)

            self.delegate?.didInitializeVungle(with: NimbusVungleError.sdkAlreadyInitialized)
        } else {
            do {
                try self.vungleRequestType.start(withAppId: appId)
            } catch {
                Nimbus.shared.logger.log("Vungle provider failed to initialize: \(error.localizedDescription)", level: .error)

                self.delegate?.didInitializeVungle(with: error)
            }
        }
    }
    
    deinit {
        vungleEventObserverType = nil
    }
}

// MARK: NimbusRequestInterceptor
/// :nodoc:
extension NimbusVungleRequestInterceptor: NimbusRequestInterceptor {
    
    /// :nodoc:
    public func modifyRequest(request: NimbusRequest) {
        Nimbus.shared.logger.log("Modifying NimbusRequest for Vungle", level: .debug)
        
        guard self.vungleRequestType.isInitialized else {
            Nimbus.shared.logger.log("Vungle has been not initialized. Skipping Vungle modification.", level: .error)
            return
        }
        
        let token = self.vungleRequestType.currentSuperToken()
        if var extensions = request.user?.extensions as? [String: NimbusCodable] {
            extensions["vungle_buyeruid"] = NimbusCodable(token)
            request.user?.extensions = extensions
        } else {
            request.user?.extensions = ["vungle_buyeruid": NimbusCodable(token)]
        }
    }
    
    /// :nodoc:
    public func didCompleteNimbusRequest(with ad: NimbusAd) {
        Nimbus.shared.logger.log("Completed NimbusRequest for Vungle", level: .debug)
    }
    
    /// :nodoc:
    public func didFailNimbusRequest(with error: NimbusError) {
        Nimbus.shared.logger.log("Failed NimbusRequest for Vungle", level: .error)
    }
}

// MARK: NimbusVungleEventObserverDelegate
/// :nodoc:
extension NimbusVungleRequestInterceptor: NimbusVungleInitDelegate {
    
    /// :nodoc:
    public func didInitialize() {
        Nimbus.shared.logger.log("Vungle provider initialized", level: .info)

        delegate?.didInitializeVungle(with: nil)
        vungleEventObserverType?.removeInitDelegate(delegate: self)
    }
    
    /// :nodoc:
    public func didFailToInitializeWithError(_ error: Error) {
        Nimbus.shared.logger.log("Vungle provider failed to initialize: \(error.localizedDescription)", level: .error)

        delegate?.didInitializeVungle(with: error)
        vungleEventObserverType?.removeInitDelegate(delegate: self)
    }
}
