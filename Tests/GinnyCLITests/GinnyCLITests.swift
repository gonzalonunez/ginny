//
//  RequestHandlerVisitorTests.swift
//
//
//  Created by Gonzalo Nuñez on 3/2/23.
//

import Foundation
import XCTest

@testable import GinnyCLI

final class GinnyCLITests: XCTestCase {

  // MARK: Lifecycle

  override func tearDownWithError() throws {
    let pagesPath = tempDirectory.appendingPathComponent("pages").path
    if fileManager.fileExists(atPath: pagesPath) {
      try fileManager.removeItem(atPath: pagesPath)
    }

    let generatedPath = tempDirectory.appendingPathComponent("generated").path
    if fileManager.fileExists(atPath: generatedPath) {
      try fileManager.removeItem(atPath: generatedPath)
    }
  }

  // MARK: Internal

  func testRequestHandler() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: pagesDirectory.path,
      withIntermediateDirectories: true)

    let indexFile = """
      import Foundation
      import Ginny
      import Vapor

      struct Index: RequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }
      """

    try fileManager.createFileThrows(
      atPath: pagesDirectory.appendingPathComponent("index.swift").path,
      contents: indexFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {
          Index().register(in: self, for: "")
        }
      }
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  func testAsyncRequestHandler() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: pagesDirectory.path,
      withIntermediateDirectories: true)

    let indexFile = """
      import Foundation
      import Ginny
      import Vapor

      // MARK: - AsyncIndex

      struct AsyncIndex: AsyncRequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) async throws -> Greeting {
          await fetchGreeting()
        }

        func fetchGreeting() async -> Greeting {
          .init(hello: "world")
        }
      }

      // MARK: - Greeting

      struct Greeting: Content {
        var hello: String
      }
      """

    try fileManager.createFileThrows(
      atPath: pagesDirectory.appendingPathComponent("index.swift").path,
      contents: indexFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {
          AsyncIndex().register(in: self, for: "")
        }
      }
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  func testMultiple() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: pagesDirectory.path,
      withIntermediateDirectories: true)

    let indexFile = #"""
      import Foundation
      import Ginny
      import Vapor

      // MARK - GetWorld

      struct GetWorld: RequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }

      // MARK - PostWorld

      struct PostWorld: RequestHandler {

        var method: HTTPMethod {
          .POST
        }

        func handle(req: Request) throws -> String {
          let body = try req.content.decode(PostWorldBody.self)
          return "Hello, \(body.name)!"
        }
      }

      struct PostWorldBody: Content {
        var name: String
      }
      """#

    try fileManager.createFileThrows(
      atPath: pagesDirectory.appendingPathComponent("index.swift").path,
      contents: indexFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {
          GetWorld().register(in: self, for: "")\n\t\tPostWorld().register(in: self, for: "")
        }
      }
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  func testNoRequestHandler() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: pagesDirectory.path,
      withIntermediateDirectories: true)

    let indexFile = """
      import Foundation
      import Ginny
      import Vapor

      struct Index {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }
      """

    try fileManager.createFileThrows(
      atPath: pagesDirectory.appendingPathComponent("index.swift").path,
      contents: indexFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    XCTAssertThrowsError(try cli.run())
  }

  func testEmpty() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: pagesDirectory.path,
      withIntermediateDirectories: true)

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {\n    \n  }\n}
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  func testFolder() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let apiDirectory = pagesDirectory.appendingPathComponent("api", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: apiDirectory.path,
      withIntermediateDirectories: true)

    let indexFile = """
      import Foundation
      import Ginny
      import Vapor

      struct APIIndex: RequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }
      """

    try fileManager.createFileThrows(
      atPath: apiDirectory.appendingPathComponent("index.swift").path,
      contents: indexFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {
          APIIndex().register(in: self, for: "api")
        }
      }
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  func testFileName() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: pagesDirectory.path,
      withIntermediateDirectories: true)

    let apiFile = """
      import Foundation
      import Ginny
      import Vapor

      struct API: RequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }
      """

    try fileManager.createFileThrows(
      atPath: pagesDirectory.appendingPathComponent("api.swift").path,
      contents: apiFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {
          API().register(in: self, for: "api")
        }
      }
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  func testSpecialIndex() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let apiDirectory = pagesDirectory.appendingPathComponent("api", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: apiDirectory.path,
      withIntermediateDirectories: true)

    let indexFile = """
      import Foundation
      import Ginny
      import Vapor

      struct APIIndex: RequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }
      """

    try fileManager.createFileThrows(
      atPath: apiDirectory.appendingPathComponent("api.index.swift").path,
      contents: indexFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {
          APIIndex().register(in: self, for: "api")
        }
      }
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  func testParameter() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let userDirectory = pagesDirectory.appendingPathComponent("user", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: userDirectory.path,
      withIntermediateDirectories: true)

    let indexFile = """
      import Foundation
      import Ginny
      import Vapor

      struct User: RequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }
      """

    try fileManager.createFileThrows(
      atPath: userDirectory.appendingPathComponent("[id].swift").path,
      contents: indexFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {
          User().register(in: self, for: "user/:id")
        }
      }
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  func testCatchall() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let userDirectory = pagesDirectory.appendingPathComponent("user", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: userDirectory.path,
      withIntermediateDirectories: true)

    let indexFile = """
      import Foundation
      import Ginny
      import Vapor

      struct User: RequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }
      """

    try fileManager.createFileThrows(
      atPath: userDirectory.appendingPathComponent("[...id].swift").path,
      contents: indexFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {
          User().register(in: self, for: "user/**")
        }
      }
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  func testCatchallOtherSlug() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let userDirectory = pagesDirectory.appendingPathComponent("user", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: userDirectory.path,
      withIntermediateDirectories: true)

    let indexFile = """
      import Foundation
      import Ginny
      import Vapor

      struct User: RequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }
      """

    try fileManager.createFileThrows(
      atPath: userDirectory.appendingPathComponent("[...slug].swift").path,
      contents: indexFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {
          User().register(in: self, for: "user/**")
        }
      }
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  func testGlobalSorting() throws {
    let pagesDirectory = tempDirectory.appendingPathComponent("pages", isDirectory: true)
    let outputDirectory = tempDirectory.appendingPathComponent("generated", isDirectory: true)

    try fileManager.createDirectory(
      atPath: pagesDirectory.path,
      withIntermediateDirectories: true)

    let userFile = """
      import Foundation
      import Ginny
      import Vapor

      struct User: RequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }
      """

    try fileManager.createFileThrows(
      atPath: pagesDirectory.appendingPathComponent("user.swift").path,
      contents: userFile.data(using: .utf8))

    let apiFile = """
      import Foundation
      import Ginny
      import Vapor

      struct API: RequestHandler {

        var method: HTTPMethod {
          .GET
        }

        func handle(req: Request) throws -> String {
          "Hello, world!"
        }
      }
      """

    try fileManager.createFileThrows(
      atPath: pagesDirectory.appendingPathComponent("api.swift").path,
      contents: apiFile.data(using: .utf8))

    var cli = GinnyCLI(
      inputDirectory: pagesDirectory,
      outputDirectory: outputDirectory)

    try cli.run()

    let expected = """
      import Vapor

      extension Application {

        func registerRoutes() {
          API().register(in: self, for: "api")\n\t\tUser().register(in: self, for: "user")
        }
      }
      """

    let routesFile = outputDirectory.appendingPathComponent("Routes.generated.swift")
    let actual = try String(contentsOf: routesFile, encoding: .utf8)
    XCTAssertEqual(expected, actual)
  }

  // MARK: Private

  private let fileManager = FileManager.default

  private var tempDirectory: URL {
    fileManager.temporaryDirectory
  }
}
