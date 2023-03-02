//
//  GinnyCLI.swift
//  
//
//  Created by Gonzalo Nuñez on 2/24/23.
//

import Foundation
import SwiftParser
import SwiftSyntax

enum GinnyError: Error {
  case failedToCreateFile(String)
  case missingInputDirectory
  case missingStructDeclaration
}

struct RouteFile {
  var routeName: String
  var url: URL
}

@main
struct GinnyCLI {

  static func main() async throws {
    let inputDirectory = CommandLine.arguments[1]
    let outputDirectory = CommandLine.arguments[2]
    try generateRoutesFile(from: inputDirectory, in: outputDirectory)
  }

  static func generateRoutesFile(
    from inputDirectory: String,
    in directory: String) throws
  {
    let routeFiles = try findRouteFiles(in: inputDirectory)

    var registrations: [String] = []
    for fileHandler in routeFiles {
      let source = try String(contentsOf: fileHandler.url, encoding: .utf8)
      let sourceFile = Parser.parse(source: source)

      let visitor = RequestHandlerVisitor(viewMode: .sourceAccurate)
      visitor.walk(sourceFile)

      for identifier in visitor.identifiers {
        registrations.append("""
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

    try FileManager.default.createFileThrows(
      atPath: directory.appending("/" + "Routes.generated.swift"),
      contents: contents.data(using: .utf8))
  }

  static func findRouteFiles(in inputDirectory: String) throws -> [RouteFile] {
    guard let enumerator = FileManager.default.enumerator(atPath: inputDirectory) else {
      throw GinnyError.missingInputDirectory
    }

    var routeFiles: [RouteFile] = []
    while let file = enumerator.nextObject() as? String {
      let swiftSuffix = ".swift"
      guard file.hasSuffix(swiftSuffix) else {
        continue
      }

      let routeComponents = try file
        .dropLast(swiftSuffix.count)
        .split(separator: "/")
        .filter { !$0.hasSuffix("index") }
        .map { try String($0).transformingParametersIfNeeded() }

      let inputPath = inputDirectory.appending("/" + file)
      let url = URL(fileURLWithPath: inputPath)
      let file = RouteFile(routeName: routeComponents.joined(separator: "/"), url: url)
      routeFiles.append(file)
    }

    return routeFiles
  }
}
