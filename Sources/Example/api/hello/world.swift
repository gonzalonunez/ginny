//
//  world.swift
//  
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import SwiftNext
import Vapor

struct GetWorld: RequestHandler {

  var method: HTTPMethod {
    .GET
  }

  func handle(req: Request) throws -> String {
    "Hello, world"
  }
}

struct PostWorld: AsyncRequestHandler {

  var method: HTTPMethod {
    .POST
  }

  func handle(req: Request) async throws -> String {
    return await getString()
  }

  func getString() async -> String {
    "Time to post"
  }
}

