//
//  main.swift
//
//
//  Created by Gonzalo Nuñez on 2/24/23.
//

import Ginny
import Vapor

let app = try Application(.detect())
defer { app.shutdown() }

app.middleware.use(DoSomethingMiddleware())
app.registerRoutes()
try app.run()
