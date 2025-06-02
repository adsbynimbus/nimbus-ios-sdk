//
//  NimbusVungleRequestInterceptor.swift
//  NimbusVungleKit
//
//  Created on 12/09/22.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit

public protocol NimbusVungleRequestInterceptorDelegate: AnyObject {
    func didInitializeVungle(with error: Error?)
}

/// Enables Vungle demand for NimbusRequest
/// Add an instance of this to `NimbusAdManager.requestInterceptors`
public final class NimbusVungleRequestInterceptor {
    
    /// Vungle app id
    private let appId: String
    
    /// VungleAds protocol
    private let vungleInitializerType: NimbusVungleInitializerType

    /// Delegate for listening Vungle callbacks
    public weak var delegate: NimbusVungleRequestInterceptorDelegate?
    
    /// Nimbus internal logger
    private let logger: Logger
    
    /// :nodoc:
    @available(*, deprecated, message: "Please use the other init instead.")
    public convenience init(
        appId: String,
        isLoggingEnabled: Bool = false,
        vungleRequestType: NimbusVungleRequestType = NimbusVungleRequest(),
        vungleEventObserverType: NimbusVungleEventObserverType = NimbusVungleEventObserver.shared,
        delegate: NimbusVungleRequestInterceptorDelegate? = nil
    ) {
        self.init(appId: appId, vungleInitializerType: NimbusVungleInitializer(), delegate: delegate)
    }
    
    /**
     Initializes a NimbusVungleRequestInterceptor instance
     
     - Parameters:
     - appId: Vungle app id
     - delegate: Object that conforms to NimbusVungleRequestInterceptorDelegate
     */
    public convenience init(
        appId: String,
        delegate: NimbusVungleRequestInterceptorDelegate? = nil
    ) {
        self.init(appId: appId, vungleInitializerType: NimbusVungleInitializer(), delegate: delegate)
    }
    
    /**
     Initializes a NimbusVungleRequestInterceptor instance
     
     - Parameters:
     - appId: Vungle app id
     - vungleInitializerType: VungleAds wrapper, use the default object
     - delegate: Object that conforms to NimbusVungleRequestInterceptorDelegate
     - logger: Logger
    */
    internal init(
        appId: String,
        vungleInitializerType: NimbusVungleInitializerType = NimbusVungleInitializer(),
        delegate: NimbusVungleRequestInterceptorDelegate? = nil,
        logger: Logger = Nimbus.shared.logger
    ) {
        self.appId = appId
        self.vungleInitializerType = vungleInitializerType
        self.delegate = delegate
        self.logger = logger
                
        if vungleInitializerType.isInitialized {
            self.logger.log("Vungle provider has been already initialized", level: .info)

            self.delegate?.didInitializeVungle(with: NimbusVungleError.sdkAlreadyInitialized)
        } else {
            vungleInitializerType.initWithAppId(appId) { error in
                if let error {
                    self.logger.log("Vungle provider failed to initialize: \(error.localizedDescription)", level: .error)
                } else {
                    self.logger.log("Vungle provider initialized.", level: .info)
                }
                self.delegate?.didInitializeVungle(with: error)
            }
        }
    }
}

// MARK: NimbusRequestInterceptor
/// :nodoc:
extension NimbusVungleRequestInterceptor: NimbusRequestInterceptor {
    
    /// :nodoc:
    public func modifyRequest(request: NimbusRequest) {
        logger.log("Modifying NimbusRequest for Vungle.", level: .debug)
                
        guard vungleInitializerType.isInitialized else {
            logger.log("Vungle has been not initialized. Skipping Vungle modification.", level: .error)
            return
        }
        
        let token = vungleInitializerType.biddingToken
        
        if request.user == nil {
            request.user = .init()
        }
        if request.user?.extensions == nil {
            request.user?.extensions = [:]
        }
        request.user?.extensions?["vungle_buyeruid"] = NimbusCodable(token)
    }
    
    /// :nodoc:
    public func didCompleteNimbusRequest(with ad: NimbusAd) {
        logger.log("Completed NimbusRequest for Vungle.", level: .debug)
    }
    
    /// :nodoc:
    public func didFailNimbusRequest(with error: NimbusError) {
        logger.log("Failed NimbusRequest for Vungle", level: .error)
    }
}
