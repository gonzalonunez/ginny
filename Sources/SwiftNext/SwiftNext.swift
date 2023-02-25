//
//  main.swift
//  
//
//  Created by Gonzalo Nuñez on 2/24/23.
//

import Foundation

enum SwiftNextError: Error {
  case missingInputDirectory
}

struct FileHandler {
  var path: String
  var contents: String
}

@main
struct SwiftNext {

  static func main() async throws {
    let inputDirectory = CommandLine.arguments[1]
    let outputDirectory = CommandLine.arguments[2]

    guard let enumerator = FileManager.default.enumerator(atPath: inputDirectory) else {
      throw SwiftNextError.missingInputDirectory
    }

    var routes: [FileHandler] = []
    while let file = enumerator.nextObject() as? String {
      let inputPath = inputDirectory.appending("/" + file)
      if
        let inputData = FileManager.default.contents(atPath: inputPath),
        let contents = String(data: inputData, encoding: .utf8)
      {
        let fileHandler = FileHandler(path: file, contents: contents)
        routes.append(fileHandler)
      }
    }

    generateAppFile(inDirectory: outputDirectory)
    generateRoutesFile(inDirectory: outputDirectory, routes: routes)
  }

  static func generateAppFile(inDirectory directory: String) {
    let contents = """
    import Vapor

    struct SwiftNext {

      static func run(app: Application) throws {
        registerRoutes(app: app)
        try app.run()
      }
    }
    """

    let didCreate = FileManager.default.createFile(
      atPath: directory.appending("/" + "App.swift"),
      contents: contents.data(using: .utf8))

    assert(didCreate)
  }

  static func generateRoutesFile(
    inDirectory directory: String,
    routes: [FileHandler])
  {
    let registerRoutesBody = """

    """

    let contents = """
    import Vapor

    extension SwiftNext {

      static func registerRoutes(app: Application) {
        \(registerRoutesBody)
      }
    }
    """

    let didCreate = FileManager.default.createFile(
      atPath: directory.appending("/" + "Routes.swift"),
      contents: contents.data(using: .utf8))

    assert(didCreate)
  }
}
