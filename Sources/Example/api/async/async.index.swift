//
//  AsyncIndex.swift
//  
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import Ginny
import Vapor

// MARK: - AsyncContent

struct AsyncContent: AsyncRequestHandler {

  var method: HTTPMethod {
    .GET
  }

  func handle(req: Request) async throws -> Greeting {
    await fetchGreeting()
  }

  func fetchGreeting() async -> Greeting {
    .init(hello: "world")
  }
}

// MARK: - Greeting

struct Greeting: Content {
  var hello: String
}
