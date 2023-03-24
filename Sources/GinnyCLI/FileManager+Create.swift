//
//  FileManager+Create.swift
//
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation

/// An extension of `FileManager` with methods for creating files.
extension FileManager {

  /**
   Creates a file at the specified path.

   - Parameters:
     - path: The path of the file to create.
     - data: The data to write to the file.
     - attr: The file attributes to set on the file.

   - Throws: `GinnyError.failedToCreateFile` if the file could not be created.
   */
  func createFileThrows(
    atPath path: String,
    contents data: Data?,
    attributes attr: [FileAttributeKey: Any]? = nil
  ) throws {
    guard createFile(atPath: path, contents: data, attributes: attr) else {
      throw GinnyError.failedToCreateFile(path)
    }
  }
}
