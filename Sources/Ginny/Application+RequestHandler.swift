//
//  Application+RequestHandler.swift
//
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import Vapor

/// Extension to `AsyncRequestHandler` to register a handler in an `Application`.
extension AsyncRequestHandler {

  /**
   Registers a handler in an `Application` for a given path.

   - Parameters:
     - app: The `Application` to register the handler in.
     - path: The path to register the handler for.
   */
  public func register(in app: Application, for path: String) {
    app.on(method, path.pathComponents) { [handle] req async throws in
      try await handle(req)
    }
  }
}

/// Extension to `RequestHandler` to register a handler in an `Application`.
extension RequestHandler {

  /**
   Registers a handler in an `Application` for a given path.

   - Parameters:
     - app: The `Application` to register the handler in.
     - path: The path to register the handler for.
   */
  public func register(in app: Application, for path: String) {
    app.on(method, path.pathComponents) { [handle] req throws in
      try handle(req)
    }
  }
}
