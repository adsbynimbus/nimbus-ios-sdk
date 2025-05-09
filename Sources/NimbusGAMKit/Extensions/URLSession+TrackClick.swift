//
//  URLSession+TrackClick.swift
//  Nimbus
//  Created on 5/6/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import NimbusCoreKit

extension URLSession {
    static func trackClick(url: URL, logger: Logger) {
        URLSession.shared.dataTask(with: URLRequest(url: url).with(userAgent: Nimbus.shared.userAgentString)) { _, _, error in
            if let error {
                logger.log(
                    "Error firing Google click tracker: \(error.localizedDescription)",
                    level: .debug
                )
            } else {
                logger.log(
                    "Google click tracker fired successfully",
                    level: .info
                )
            }
        }.resume()
    }
}
