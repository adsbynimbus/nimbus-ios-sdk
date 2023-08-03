//
//  NimbusLiveRampInterceptor.swift
//  NimbusLiveRampKit
//
//  Created by Victor Takai on 19/07/22.
//  Copyright © 2022 Timehop. All rights reserved.
//

@_exported import NimbusRequestKit
import LRAtsSDK

/// Delegate for listening LiveRamp's initialization and envelope fetching
public protocol NimbusLiveRampInterceptorDelegate {
    
    /// Triggered when initialized with either success or error
    func didInitializeLiveRamp(error: Error?)
    
    /// Triggered when envelope is fetched with either success or error
    @available(*, deprecated, renamed: "didFetchLiveRampEnvelope(envelope:error:)")
    func didFetchLiveRampEnvelope(error: Error?)
    
    /// Triggered when envelope is fetched with either success or error
    func didFetchLiveRampEnvelope(envelope: LREnvelope?, error: Error?)
}

/// :nodoc:
public extension NimbusLiveRampInterceptorDelegate {
    func didFetchLiveRampEnvelope(error: Error?) {}
    func didFetchLiveRampEnvelope(envelope: LREnvelope?, error: Error?) {}
}

public enum NimbusLiveRampError: LocalizedError, Equatable {
    case identifierNotFound
    
    public var errorDescription: String? {
        "No e-mail or phone number found"
    }
}

/// Enables LiveRamp integration for NimbusRequest
/// Add an instance of this to `NimbusAdManager.requestInterceptors`
public final class NimbusLiveRampInterceptor {
    
    /// LiveRamp configuration identifier
    private(set) var configId: String
    
    /// Possible e-mail used as identifier
    private(set) var email: String?
    
    /// Possible phone number used as identifier
    private(set) var phoneNumber: String?
    
    /// Boolean for toggling LiveRamps's hasConsentForNoLegislation
    /// Should be set before initializing an instance of this class if needed
    private(set) var hasConsentForNoLegislation: Bool {
        get { LRAts.shared.hasConsentForNoLegislation }
        set { LRAts.shared.hasConsentForNoLegislation = newValue }
    }
    
    /// Delegate for listening LiveRamp callbacks
    public var delegate: NimbusLiveRampInterceptorDelegate?
    
    var liveRampEnvelope: String?
    
    /**
     Initializes a NimbusLiveRampInterceptor instance
     
     - Parameters:
     - configId: LiveRamp's configuration identifier
     - email: E-mail of the user
     - phoneNumber: Phone number of the user
     - hasConsentForNoLegislation: Boolean for toggling LiveRamps's hasConsentForNoLegislation
     - isTestMode: Boolean for toggling test mode
     - delegate: Object that conforms to NimbusLiveRampInterceptorDelegate
     */
    private init(
        configId: String,
        email: String?,
        phoneNumber: String?,
        hasConsentForNoLegislation: Bool,
        isTestMode: Bool,
        delegate: NimbusLiveRampInterceptorDelegate?
    ) {
        self.configId = configId
        self.email = email
        self.phoneNumber = phoneNumber
        self.hasConsentForNoLegislation = hasConsentForNoLegislation
        self.delegate = delegate
        
        let configuration = LRAtsConfiguration(
            appId: configId,
            isTestMode: isTestMode,
            logToFileEnabled: false
        )
        
        LRAts.shared.initialize(with: configuration) { [weak self] success, error in
            self?.delegate?.didInitializeLiveRamp(error: error)
            if success { self?.getEnvelope() }
        }
    }
    
    /**
     Initializes a NimbusLiveRampInterceptor instance
     
     - Parameters:
     - configId: LiveRamp's configuration identifier
     - email: E-mail of the user
     - hasConsentForNoLegislation: Boolean for toggling LiveRamps's hasConsentForNoLegislation
     - isTestMode: Boolean for toggling test mode
     - delegate: Object that conforms to NimbusLiveRampInterceptorDelegate
     */
    public convenience init(
        configId: String,
        email: String,
        hasConsentForNoLegislation: Bool = false,
        isTestMode: Bool = false,
        delegate: NimbusLiveRampInterceptorDelegate? = nil
    ) {
        self.init(
            configId: configId,
            email: email,
            phoneNumber: nil,
            hasConsentForNoLegislation: hasConsentForNoLegislation,
            isTestMode: isTestMode,
            delegate: delegate
        )
    }
    
    /**
     Initializes a NimbusLiveRampInterceptor instance
     
     - Parameters:
     - configId: LiveRamp's configuration identifier
     - phoneNumber: Phone number of the user
     - hasConsentForNoLegislation: Boolean for toggling LiveRamps's hasConsentForNoLegislation
     - isTestMode: Boolean for toggling test mode
     - delegate: Object that conforms to NimbusLiveRampInterceptorDelegate
     */
    public convenience init(
        configId: String,
        phoneNumber: String,
        hasConsentForNoLegislation: Bool = false,
        isTestMode: Bool = false,
        delegate: NimbusLiveRampInterceptorDelegate? = nil
    ) {
        self.init(
            configId: configId,
            email: nil,
            phoneNumber: phoneNumber,
            hasConsentForNoLegislation: hasConsentForNoLegislation,
            isTestMode: isTestMode,
            delegate: delegate
        )
    }
    
    private func getEnvelope() {
        let identifierData: LRIdentifierData
        
        if let email {
            identifierData = LREmailIdentifier(email)
        } else if let phoneNumber {
            identifierData = LRPhoneNumberIdentifier(phoneNumber)
        } else {
            delegate?.didInitializeLiveRamp(error: NimbusLiveRampError.identifierNotFound)
            return
        }
        
        LRAts.shared.getEnvelope(identifierData) { [weak self] envelope, error in
            self?.liveRampEnvelope = envelope?.envelope
            self?.delegate?.didFetchLiveRampEnvelope(error: error)
            self?.delegate?.didFetchLiveRampEnvelope(envelope: envelope, error: error)
        }
    }
    
    private var liveRampExtendedId: NimbusExtendedId? {
        guard let liveRampEnvelope else { return nil }

        var extendedId = NimbusExtendedId(source: "liveramp.com", id: liveRampEnvelope)
        extendedId.extensions = ["rtiPartner": NimbusCodable("idl")]
        return extendedId
    }
}

// MARK: NimbusRequestInterceptor
/// :nodoc:
extension NimbusLiveRampInterceptor: NimbusRequestInterceptor {
    
    /// :nodoc:
    public func modifyRequest(request: NimbusRequest) {
        Nimbus.shared.logger.log("Modifying NimbusRequest for LiveRamp", level: .debug)
        
        if let liveRampExtendedId {
            request.addExtendedId(liveRampExtendedId)
        }
    }

    /// :nodoc:
    public func didCompleteNimbusRequest(with ad: NimbusAd) {}
    
    /// :nodoc:
    public func didFailNimbusRequest(with error: NimbusError) {}
}
