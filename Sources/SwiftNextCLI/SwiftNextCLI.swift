//
//  SwiftNextCLI.swift
//  
//
//  Created by Gonzalo Nuñez on 2/24/23.
//

import Foundation
import SwiftParser
import SwiftSyntax

enum SwiftNextError: Error {
  case failedToCreateFile(String)
  case missingInputDirectory
  case missingStructDeclaration
}

struct File {
  var name: String
  var url: URL
}

@main
struct SwiftNextCLI {

  static func main() async throws {
    let inputDirectory = CommandLine.arguments[1]
    let outputDirectory = CommandLine.arguments[2]

    guard let enumerator = FileManager.default.enumerator(atPath: inputDirectory) else {
      throw SwiftNextError.missingInputDirectory
    }

    var routes: [File] = []
    while let file = enumerator.nextObject() as? String {
      let indexSuffix = "index"
      let swiftSuffix = ".swift"
      guard file.hasSuffix(swiftSuffix) else {
        continue
      }

      var routeName = "api/" + file.dropLast(swiftSuffix.count)
      if routeName.hasSuffix(indexSuffix) {
        routeName = String(routeName.dropLast(indexSuffix.count))
      }

      let inputPath = inputDirectory.appending("/" + file)
      let url = URL(fileURLWithPath: inputPath)
      let file = File(name: routeName, url: url)
      routes.append(file)
    }

    try generateAppFile(inDirectory: outputDirectory)
    try generateRoutesFile(inDirectory: outputDirectory, routes: routes)
  }

  static func generateAppFile(inDirectory directory: String) throws {
    let contents = """
    import Vapor

    enum SwiftNext {

      static func run(app: Application) throws {
        registerRoutes(app: app)
        try app.run()
      }
    }
    """

    let fileName = directory.appending("/" + "App.generated.swift")

    let didCreate = FileManager.default.createFile(
      atPath: fileName,
      contents: contents.data(using: .utf8))

    if !didCreate {
      throw SwiftNextError.failedToCreateFile(fileName)
    }
  }

  static func generateRoutesFile(
    inDirectory directory: String,
    routes: [File]) throws
  {
    var registrations: [String] = []
    for fileHandler in routes {
      let source = try String(contentsOf: fileHandler.url, encoding: .utf8)
      let sourceFile = Parser.parse(source: source)

      let visitor = RequestHandlerVisitor(viewMode: .sourceAccurate)
      visitor.walk(sourceFile)

      for identifiers in visitor.identifiers {
        registrations.append("""
        \(identifiers)().register(in: app, for: \"\(fileHandler.name)\")
        """)
      }
    }

    let contents = """
    import Vapor

    extension SwiftNext {

      static func registerRoutes(app: Application) {
        \(registrations.joined(separator: "\n"))
      }
    }
    """

    let fileName = directory.appending("/" + "Routes.generated.swift")

    let didCreate = FileManager.default.createFile(
      atPath: fileName,
      contents: contents.data(using: .utf8))

    if !didCreate {
      throw SwiftNextError.failedToCreateFile(fileName)
    }
  }
}
