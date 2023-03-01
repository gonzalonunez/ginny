//
//  [...slug].swift
//  
//
//  Created by Gonzalo Nuñez on 3/1/23.
//

import Foundation
import SwiftNext
import Vapor

struct Post: RequestHandler {

  var method: HTTPMethod {
    .GET
  }

  func handle(req: Request) throws -> String {
    req.parameters.getCatchall().joined(separator: "/")
  }
}
