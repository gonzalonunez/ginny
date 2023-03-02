//
//  ParameterTests.swift
//  
//
//  Created by Gonzalo Nuñez on 3/2/23.
//

import Foundation
import XCTest

@testable import GinnyCLI

final class ParameterTests: XCTestCase {

  func testParameter() throws {
    let actual = try "[foo]".transformingParametersIfNeeded()
    XCTAssertEqual(":foo", actual)
  }

  func testDoubleParameter() throws {
    let actual = try "[[foo]]".transformingParametersIfNeeded()
    XCTAssertEqual(":[foo]", actual)
  }

  func testCatchall() throws {
    let actual = try "[...foo]".transformingParametersIfNeeded()
    XCTAssertEqual("**", actual)
  }

  func testCatchallOther() throws {
    let actual = try "[...slug]".transformingParametersIfNeeded()
    XCTAssertEqual("**", actual)
  }

  func testNoParameter() throws {
    let actual = try "foo".transformingParametersIfNeeded()
    XCTAssertEqual("foo", actual)
  }

  func testEmpty() throws {
    let actual = try "".transformingParametersIfNeeded()
    XCTAssertEqual("", actual)
  }
}
