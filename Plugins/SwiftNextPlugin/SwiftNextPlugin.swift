//
//  main.swift
//  
//
//  Created by Gonzalo Nuñez on 2/24/23.
//

import Foundation
import PackagePlugin

enum SwiftNextPluginError: Error {
  case missingAPIDirectory
}

@main
struct SwiftNextPlugin: BuildToolPlugin {

  func createBuildCommands(
    context: PluginContext,
    target: Target) async throws -> [Command]
  {
    let apiDirectory = target.directory.appending(["api"])
    let tempDirectory = context.pluginWorkDirectory.appending(["tmp"])

    let inputPaths = try copyFiles(from: apiDirectory, to: tempDirectory)
    var outputPaths: [Path] = []

    let outputDirectory = context.pluginWorkDirectory.appending(["api"])

    let appPath = outputDirectory.appending(["App.swift"])
    outputPaths.append(appPath)

    let routesPath = outputDirectory.appending(["Routes.swift"])
    outputPaths.append(routesPath)

    return [
      .buildCommand(
        displayName: "SwiftNext",
        executable: try context.tool(named: "SwiftNext").path,
        arguments: [
          tempDirectory,
          outputDirectory,
        ],
        inputFiles: inputPaths,
        outputFiles: outputPaths),
    ]
  }

  func copyFiles(
    from apiDirectory: Path,
    to tempDirectory: Path) throws -> [Path]
  {
    if !FileManager.default.fileExists(atPath: tempDirectory.string, isDirectory: nil) {
      try FileManager.default.createDirectory(
        atPath: tempDirectory.string,
        withIntermediateDirectories: false)
    }

    guard let enumerator = FileManager.default.enumerator(atPath: apiDirectory.string) else {
      throw SwiftNextPluginError.missingAPIDirectory
    }

    var inputPaths: [Path] = []

    while let file = enumerator.nextObject() as? String {
      let swiftSuffix = ".swift"
      guard file.hasSuffix(swiftSuffix) else {
        continue
      }

      let inputPath = apiDirectory.appending([file])
      inputPaths.append(inputPath)

      let didCreate = FileManager.default.createFile(
        atPath: tempDirectory.appending([file]).string,
        contents: FileManager.default.contents(atPath: inputPath.string))

      assert(didCreate)
    }

    return inputPaths
  }
}
