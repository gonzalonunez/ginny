//
//  GinnyTests.swift
//
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Vapor
import XCTVapor
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

  func testMiddleware() async throws {
    let app = Application(.testing)
    defer { app.shutdown() }

    app.middleware.use(DoSomethingMiddleware())
    AsyncIndex().register(in: app, for: "api/async")
    Index().register(in: app, for: "api/sync")

    try app.test(.GET, "api/async") { response in
      XCTAssertEqual(String(buffer: response.body), "Hello, world")
      XCTAssertTrue(response.headers.contains(name: "Something-Header"))
      XCTAssertTrue(response.headers.contains(name: "Something-Else-Header"))
    }

    try app.test(.GET, "api/sync") { response in
      XCTAssertEqual(String(buffer: response.body), "Hello, world")
      XCTAssertTrue(response.headers.contains(name: "Something-Header"))
      XCTAssertFalse(response.headers.contains(name: "Something-Else-Header"))
    }
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

  var middlewares: [Middleware] = [DoSomethingElseMiddleware()]
}

// MARK: - Middlewares

struct DoSomethingMiddleware: AsyncMiddleware {
  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    let response = try await next.respond(to: request)
    response.headers.add(name: "Something-Header", value: "Something")
    return response
  }
}

struct DoSomethingElseMiddleware: AsyncMiddleware {
  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    let response = try await next.respond(to: request)
    response.headers.add(name: "Something-Else-Header", value: "Something Else")
    return response
  }
}
