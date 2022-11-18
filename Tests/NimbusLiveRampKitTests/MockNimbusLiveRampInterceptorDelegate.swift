//
//  MockNimbusLiveRampInterceptorDelegate.swift
//  NimbusLiveRampKitTests
//
//  Created by Victor Takai on 01/08/22.
//  Copyright © 2022 Timehop. All rights reserved.
//

@testable import NimbusLiveRampKit

final class MockNimbusLiveRampInterceptorDelegate: NimbusLiveRampInterceptorDelegate {
    
    private(set) var didTryToInitializeLiveRamp = false
    private(set) var didInitializeLiveRampError: Error?
    
    private(set) var didTryToFetchLiveRampEnvelope = false
    private(set) var didFetchLiveRampEnvelopeError: Error?
    
    func didInitializeLiveRamp(error: Error?) {
        didTryToInitializeLiveRamp = true
        didInitializeLiveRampError = error
    }
    
    func didFetchLiveRampEnvelope(error: Error?) {
        didTryToFetchLiveRampEnvelope = true
        didFetchLiveRampEnvelopeError = error
    }
}
