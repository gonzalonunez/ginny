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

enum GinnyError: Error {
  case failedToCreateFile(String)
  case missingInputDirectory
  case noRequestHandlersFound
}

struct RouteFile {
  var routeName: String
  var url: URL
}

@main
struct GinnyCLI: ParsableCommand {

  mutating func run() throws {
    try generateRoutesFile()
  }

  // MARK: Internal

  @Argument(help: "The directory containing your routes")
  var inputDirectory: URL

  @Argument(help: "The directory in which to generate code")
  var outputDirectory: URL

  // MARK: Private

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

  public init?(argument: String) {
    self.init(fileURLWithPath: argument, isDirectory: true)  // We're working with local directory URLs only
  }
}

// MARK: - GinnyCLI

#if DEBUG
  extension GinnyCLI {

    init(inputDirectory: URL, outputDirectory: URL) {
      self.inputDirectory = inputDirectory
      self.outputDirectory = outputDirectory
    }
  }
#endif
