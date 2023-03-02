//
//  AsyncRequestHandler.swift
//
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import Vapor

public protocol AsyncRequestHandler {
  init()
  associatedtype Response: AsyncResponseEncodable
  var method: HTTPMethod { get }
  func handle(req: Request) async throws -> Response
}
