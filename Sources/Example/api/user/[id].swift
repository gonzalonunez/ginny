//
//  [id].swift
//  
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import SwiftNext
import Vapor

struct UserID: RequestHandler {

  var method: HTTPMethod {
    .GET
  }

  func handle(req: Request) throws -> User {
    let id = req.parameters.get("id")!
    return User(id: id)
  }
}

struct User: Content {
  var id: String
}
