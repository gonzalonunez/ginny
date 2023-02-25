//
//  main.swift
//  
//
//  Created by Gonzalo Nuñez on 2/24/23.
//

import Vapor

let app = try Application(.detect())
defer { app.shutdown() }

try SwiftNext.run(app: app)
