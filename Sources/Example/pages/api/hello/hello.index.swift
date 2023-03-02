//
//  hello.index.swift
//  
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import Ginny
import Vapor

struct HelloIndex: RequestHandler {

  var method: HTTPMethod {
    .GET
  }

  func handle(req: Request) throws -> String {
    "Hello, world!"
  }
}
