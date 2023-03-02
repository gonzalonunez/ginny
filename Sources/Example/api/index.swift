//
//  index.swift
//  
//
//  Created by Gonzalo Nuñez on 2/24/23.
//

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
