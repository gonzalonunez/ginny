//
//  Middlewares.swift
//  
//
//  Created by Mauricio Cardozo on 27/07/23.
//

import Foundation
import Vapor

struct DoSomethingMiddleware: AsyncMiddleware {
  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    let response = try await next.respond(to: request)
    response.headers.add(name: "Something-Header", value: "Something")
    return response
  }
}

struct DoSomethingElseMiddleware: AsyncMiddleware {
  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    let response = try await next.respond(to: request)
    response.headers.add(name: "Something-Else-Header", value: "Something Else")
    return response
  }
}
