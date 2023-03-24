//
//  GinnyCLI.swift
//
//
//  Created by Gonzalo Nuñez on 2/24/23.
//

import ArgumentParser
import Foundation
import SwiftParser
import SwiftSyntax

/// Errors thrown by `GinnyCLI`.
enum GinnyError: Error {
  /// Thrown when a file fails to be created.
  case failedToCreateFile(String)

  /// Thrown when the input directory is missing.
  case missingInputDirectory

  /// Thrown when no request handlers are found.
  case noRequestHandlersFound
}

/// A `struct` representing a route file.
struct RouteFile {
  /// The name of the route.
  var routeName: String

  /// The `URL` of the route file.
  var url: URL
}

/// The main entry point for the `GinnyCLI` command line tool.
@main
struct GinnyCLI: ParsableCommand {

  /// Runs the command.
  mutating func run() throws {
    try generateRoutesFile()
  }

  // MARK: Internal

  /// The directory containing your routes.
  @Argument(help: "The directory containing your routes")
  var inputDirectory: URL

  /// The directory in which to generate code.
  @Argument(help: "The directory in which to generate code")
  var outputDirectory: URL

  // MARK: Private

  /// Generates the routes file.
  private func generateRoutesFile() throws {
    let routeFiles = try findRouteFiles().sorted { lhs, rhs in
      lhs.routeName < rhs.routeName
    }

    var registrations: [String] = []
    for fileHandler in routeFiles {
      let source = try String(contentsOf: fileHandler.url, encoding: .utf8)
      let sourceFile = Parser.parse(source: source)

      let visitor = RequestHandlerVisitor(viewMode: .sourceAccurate)
      visitor.walk(sourceFile)

      if visitor.identifiers.isEmpty {
        throw GinnyError.noRequestHandlersFound
      }

      for identifier in visitor.identifiers.sorted() {
        registrations.append(
          """
          \(identifier)().register(in: self, for: \"\(fileHandler.routeName)\")
          """)
      }
    }

    let contents = """
      import Vapor

      extension Application {

        func registerRoutes() {
          \(registrations.joined(separator: "\n\t\t"))
        }
      }
      """

    if !FileManager.default.fileExists(atPath: outputDirectory.path, isDirectory: nil) {
      try FileManager.default.createDirectory(
        at: outputDirectory,
        withIntermediateDirectories: true)
    }

    try FileManager.default.createFileThrows(
      atPath: outputDirectory.appendingPathComponent("Routes.generated.swift").path,
      contents: contents.data(using: .utf8))
  }

  /// Finds all route files.
  private func findRouteFiles() throws -> [RouteFile] {
    guard let enumerator = FileManager.default.enumerator(atPath: inputDirectory.path) else {
      throw GinnyError.missingInputDirectory
    }

    var routeFiles: [RouteFile] = []
    while let file = enumerator.nextObject() as? String {
      let swiftSuffix = ".swift"
      guard file.hasSuffix(swiftSuffix) else {
        continue
      }

      let routeComponents =
        try file
        .dropLast(swiftSuffix.count)
        .split(separator: "/")
        .filter { !$0.hasSuffix("index") }
        .map { try String($0).transformingParametersIfNeeded() }

      let fileURL = inputDirectory.appendingPathComponent(file)
      let file = RouteFile(routeName: routeComponents.joined(separator: "/"), url: fileURL)
      routeFiles.append(file)
    }

    return routeFiles
  }
}

// MARK: - URL

extension URL: ExpressibleByArgument {

  /// Creates a new `URL` from an argument.
  public init?(argument: String) {
    self.init(fileURLWithPath: argument, isDirectory: true)  // We're working with local directory URLs only
  }
}

// MARK: - GinnyCLI

#if DEBUG
  extension GinnyCLI {

    /// Creates a new `GinnyCLI` instance.
    init(inputDirectory: URL, outputDirectory: URL) {
      self.inputDirectory = inputDirectory
      self.outputDirectory = outputDirectory
    }
  }
#endif
