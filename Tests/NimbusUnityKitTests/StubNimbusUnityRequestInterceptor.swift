//
//  StubNimbusUnityRequestInterceptor.swift
//  NimbusUnityKitTests
//
//  Created by Inder Dhir on 12/14/21.
//  Copyright © 2021 Timehop. All rights reserved.
//

@testable import NimbusUnityKit

final class StubNimbusUnityRequestInterceptor: NimbusUnityRequestInterceptor {

    override var isSupported: Bool { true }
    override var isInitialized: Bool { true }
    override var token: String? { "token" }
}
