//
//  main.swift
//  
//
//  Created by Gonzalo Nuñez on 2/24/23.
//

import Foundation
import PackagePlugin

enum GinnyPluginError: Error {
  case missingAPIDirectory
}

@main
struct GinnyPlugin: BuildToolPlugin {

  func createBuildCommands(
    context: PluginContext,
    target: Target) async throws -> [Command]
  {
    let pagesDirectory = target.directory.appending(["pages"])
    let tempDirectory = context.pluginWorkDirectory.appending(["tmp"])
    let outputDirectory = context.pluginWorkDirectory.appending(["generated"])
    
    let inputPaths = try copyFiles(from: pagesDirectory, to: tempDirectory)
    let outputPaths = [
      outputDirectory.appending(["Routes.generated.swift"])
    ]

    return [
      .buildCommand(
        displayName: "GinnyCLI",
        executable: try context.tool(named: "GinnyCLI").path,
        arguments: [
          tempDirectory,
          outputDirectory,
        ],
        inputFiles: inputPaths,
        outputFiles: outputPaths),
    ]
  }

  func copyFiles(
    from pagesDirectory: Path,
    to tempDirectory: Path) throws -> [Path]
  {
    /// Delete `tempDirectory` if it exists (from a previous run)
    if FileManager.default.fileExists(atPath: tempDirectory.string, isDirectory: nil) {
      try FileManager.default.removeItem(atPath: tempDirectory.string)
    }

    /// Copy all files over from `pagesDirectory` to `tempDirectory`
    try FileManager.default.copyItem(
      atPath: pagesDirectory.string,
      toPath: tempDirectory.string)

    /// Return input paths by doing a deep search of the `pagesDirectory` directory
    guard let enumerator = FileManager.default.enumerator(atPath: pagesDirectory.string) else {
      throw GinnyPluginError.missingAPIDirectory
    }

    var inputPaths: [Path] = []
    while let file = enumerator.nextObject() as? String {
      let swiftSuffix = ".swift"
      guard file.hasSuffix(swiftSuffix) else {
        continue
      }
      let inputPath = pagesDirectory.appending([file])
      inputPaths.append(inputPath)
    }
    return inputPaths
  }
}
