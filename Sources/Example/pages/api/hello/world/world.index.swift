//
//  world.swift
//
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import Ginny
import Vapor

// MARK - GetWorld

struct GetWorld: RequestHandler {

  var method: HTTPMethod {
    .GET
  }

  func handle(req: Request) throws -> String {
    "Hello, world!"
  }

  var middlewares: [Middleware] = [
    DoSomethingElseMiddleware()
  ]
}

// MARK - PostWorld

struct PostWorld: RequestHandler {

  var method: HTTPMethod {
    .POST
  }

  func handle(req: Request) throws -> String {
    let body = try req.content.decode(PostWorldBody.self)
    return "Hello, \(body.name)!"
  }
}

struct PostWorldBody: Content {
  var name: String
}
