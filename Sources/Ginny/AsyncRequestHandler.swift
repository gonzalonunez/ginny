//
//  AsyncRequestHandler.swift
//
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import Vapor

/// A protocol for handling asynchronous requests.
public protocol AsyncRequestHandler {
  /// Creates a new instance of the handler.
  init()

  /// The associated type of the response.
  associatedtype Response: AsyncResponseEncodable

  /// The HTTP method of the request.
  var method: HTTPMethod { get }

  /// Handles the request and returns a response.
  ///
  /// - Parameter req: The incoming request.
  ///
  /// - Throws: Any errors that occur while handling the request.
  ///
  /// - Returns: An `AsyncResponseEncodable` response.
  func handle(req: Request) async throws -> Response
}

