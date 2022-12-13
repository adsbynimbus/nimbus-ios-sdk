//
//  NimbusSizeToFormatMapperTests.swift
//  NimbusGAMKitTests
//
//  Created by Inder Dhir on 12/1/22.
//  Copyright © 2022 Timehop. All rights reserved.
//

@testable import NimbusGAMKit
import XCTest

final class NimbusSizeToFormatMapperTests: XCTestCase {

    var mapper: NimbusSizeToFormatMapper!
    
    override func setUp() {
        mapper = NimbusSizeToFormatMapper()
    }

    func test_casesWhereSizeUsedAsIs() {
        XCTAssertEqual(mapper.map(width: 768, height: 1024), .init(width: 768, height: 1024))
        XCTAssertEqual(mapper.map(width: 1024, height: 768), .init(width: 1024, height: 768))
        XCTAssertNotEqual(mapper.map(width: 767, height: 1024), .init(width: 767, height: 1024))
    }

    func test_casesWhere320By50BannerIsUsed() {
        XCTAssertEqual(mapper.map(width: 320, height: 90), .init(width: 320, height: 50))
        XCTAssertNotEqual(mapper.map(width: 728, height: 90), .init(width: 320, height: 50))
    }

    func test_casesWhere728y90BannerIsUsed() {
        XCTAssertEqual(mapper.map(width: 728, height: 90), .init(width: 728, height: 90))
        XCTAssertNotEqual(mapper.map(width: 728, height: 250), .init(width: 728, height: 90))
    }

    func test_casesWhere480By320BannerIsUsed() {
        XCTAssertEqual(mapper.map(width: 480, height: 320), .init(width: 480, height: 320))
        XCTAssertNotEqual(mapper.map(width: 479, height: 320), .init(width: 480, height: 320))
        XCTAssertNotEqual(mapper.map(width: 480, height: 319), .init(width: 480, height: 320))
    }

    func test_casesWhere320By480BannerIsUsed() {
        XCTAssertEqual(mapper.map(width: 320, height: 480), .init(width: 320, height: 480))
        XCTAssertNotEqual(mapper.map(width: 320, height: 479), .init(width: 320, height: 480))
        XCTAssertNotEqual(mapper.map(width: 319, height: 480), .init(width: 320, height: 480))
    }

    func test_casesWhere300By600BannerIsUsed() {
        XCTAssertEqual(mapper.map(width: 300, height: 600), .init(width: 300, height: 600))
        XCTAssertNotEqual(mapper.map(width: 320, height: 600), .init(width: 300, height: 600))
        XCTAssertNotEqual(mapper.map(width: 300, height: 599), .init(width: 300, height: 600))
    }

    func test_casesWhere300By250BannerIsUsed() {
        XCTAssertEqual(mapper.map(width: 300, height: 250), .init(width: 300, height: 250))
        XCTAssertEqual(mapper.map(width: 320, height: 300), .init(width: 300, height: 250))
        XCTAssertEqual(mapper.map(width: 480, height: 275), .init(width: 300, height: 250))
        XCTAssertEqual(mapper.map(width: 600, height: 300), .init(width: 300, height: 250))
    }
}
