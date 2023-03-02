//
//  GinnyTests.swift
//  
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Vapor
import XCTest

@testable import Ginny

// MARK: - RequestHandlerTests

final class RequestHandlerTests: XCTestCase {

  func testRegister() {
    let app = Application(.development)
    defer { app.shutdown() }

    Index().register(in: app, for: "")

    XCTAssertEqual(app.routes.all.count, 1)
    XCTAssertTrue(app.routes.all.contains { $0.path.string == "" })
  }

  func testAsyncRegister() {
    let app = Application(.development)
    defer { app.shutdown() }
    
    AsyncIndex().register(in: app, for: "api/hello")

    XCTAssertEqual(app.routes.all.count, 1)
    XCTAssertTrue(app.routes.all.contains { $0.path.string == "api/hello" })
  }
}

// MARK: - Index

struct Index: RequestHandler {

  var method: HTTPMethod {
    .GET
  }

  func handle(req: Request) throws -> some ResponseEncodable {
    "Hello, world"
  }
}

// MARK: - AsyncIndex

struct AsyncIndex: AsyncRequestHandler {

  var method: HTTPMethod {
    .GET
  }

  func handle(req: Request) async throws -> some AsyncResponseEncodable {
    "Hello, world"
  }
}
