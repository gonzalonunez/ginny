//
//  RequestHandler.swift
//
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import Vapor

public protocol RequestHandler {
  init()
  associatedtype Response: ResponseEncodable
  var method: HTTPMethod { get }
  func handle(req: Request) throws -> Response
}
