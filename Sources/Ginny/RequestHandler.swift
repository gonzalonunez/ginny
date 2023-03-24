//
//  RequestHandler.swift
//
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import Vapor

/// A protocol for handling requests.
public protocol RequestHandler {
  /// Initializes a new `RequestHandler`.
  init()

  /// The associated type of the response.
  associatedtype Response: ResponseEncodable

  /// The HTTP method of the request.
  var method: HTTPMethod { get }

  /// Handles a request and returns a response.
  ///
  /// - Parameter req: The request to be handled.
  ///
  /// - Throws: Any errors that occur while handling the request.
  ///
  /// - Returns: The response to the request.
  func handle(req: Request) throws -> Response
}
