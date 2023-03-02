//
//  Application+RequestHandler.swift
//
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import Vapor

extension AsyncRequestHandler {

  public func register(in app: Application, for path: String) {
    app.on(method, path.pathComponents) { [handle] req async throws in
      try await handle(req)
    }
  }
}

extension RequestHandler {

  public func register(in app: Application, for path: String) {
    app.on(method, path.pathComponents) { [handle] req throws in
      try handle(req)
    }
  }
}
