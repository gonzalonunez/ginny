//
//  FileManager+Create.swift
//  
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation

extension FileManager {

  func createFileThrows(
    atPath path: String,
    contents data: Data?,
    attributes attr: [FileAttributeKey : Any]? = nil) throws
  {
    guard createFile(atPath: path, contents: data, attributes: attr) else {
      throw SwiftNextError.failedToCreateFile(path)
    }
  }
}
