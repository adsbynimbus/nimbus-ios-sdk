//
//  NimbusLiveRampInterceptor.swift
//  NimbusLiveRampKit
//
//  Created on 19/07/22.
//  Copyright © 2022 Nimbus Advertising Solutions Inc. All rights reserved.
//

@_exported import NimbusRequestKit
import LRAtsSDK

/// Delegate for listening LiveRamp's initialization and envelope fetching
public protocol NimbusLiveRampInterceptorDelegate: AnyObject {
    
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
    case errorStatus
    case disabled
    
    public var errorDescription: String? {
        switch self {
        case .identifierNotFound: return "No e-mail or phone number found"
        case .errorStatus: return "Couldn't initialize LiveRamp - LRAts.shared.status is .error"
        case .disabled: return "Couldn't initialize LiveRamp - it's disabled"
        }
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
    public weak var delegate: NimbusLiveRampInterceptorDelegate?
    
    private var canRetryInit: Bool = true
    
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
        
        initializeLiveRamp(isTestMode: isTestMode)
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
    
    private func initializeLiveRamp(isTestMode: Bool) {
        let configuration = LRAtsConfiguration(
            configID: configId,
            isTestMode: isTestMode,
            logToFileEnabled: false
        )
        
        switch LRAts.shared.status {
        case .notInitialized:
            LRAts.shared.initialize(with: configuration) { [weak self] success, error in
                self?.delegate?.didInitializeLiveRamp(error: error)
                if success { self?.getEnvelope() }
            }
        case .ready:
            self.delegate?.didInitializeLiveRamp(error: nil)
            getEnvelope()
        case .loading:
            guard canRetryInit else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.initializeLiveRamp(isTestMode: isTestMode)
            }
        case .error:
            delegate?.didInitializeLiveRamp(error: NimbusLiveRampError.errorStatus)
        case .disabled:
            delegate?.didInitializeLiveRamp(error: NimbusLiveRampError.disabled)
        @unknown default:
            Nimbus.shared.logger.log("Unknown LiveRamp status: \(LRAts.shared.status)", level: .debug)
        }
        
        canRetryInit = false
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
            if let envelope {
                NimbusRequestManager.attachLiveRamp(envelope: envelope)
            }
            
            self?.delegate?.didFetchLiveRampEnvelope(error: error)
            self?.delegate?.didFetchLiveRampEnvelope(envelope: envelope, error: error)
        }
    }
}

// MARK: NimbusRequestInterceptor
/// :nodoc:
extension NimbusLiveRampInterceptor: NimbusRequestInterceptor {
    
    /// :nodoc:
    public func modifyRequest(request: NimbusRequest) {
        // no-op
    }

    /// :nodoc:
    public func didCompleteNimbusRequest(with ad: NimbusAd) {}
    
    /// :nodoc:
    public func didFailNimbusRequest(with error: NimbusError) {}
}

private extension NimbusRequestManager {
    static func attachLiveRamp(envelope: LREnvelope) {
        if NimbusRequestManager.extendedIds == nil { NimbusRequestManager.extendedIds = [] }
        
        if let unwrappedEnvelope = envelope.envelope {
            NimbusRequestManager.extendedIds?.insert(
                NimbusExtendedId(
                    source: "liveramp.com",
                    uids: [.init(id: unwrappedEnvelope, extensions: ["rtiPartner": NimbusCodable("idl")])]
                )
            )
        }
        
        if let pairIds = envelope.pairIds {
            let uids = pairIds.map { NimbusExtendedId.UID(id: $0, atype: 571187) }
            NimbusRequestManager.extendedIds?.insert(NimbusExtendedId(source: "google.com", uids: uids))
        }
    }
}
