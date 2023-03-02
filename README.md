# Ginny 💧

Ginny is a [Swift Package plugin](https://developer.apple.com/videos/play/wwdc2022/110359/) that enables file-based routing for [Vapor](https://vapor.codes) apps. It works by generating code at build-time that registers routes like you would in any normal Vapor app.

## Basic Usage

Ginny removes some of the boilerplate related to routing in Vapor apps while supporting the majority of its features. (For a list of unsupported features, see below.)

Using Ginny is as simple as a one-line change:
```diff
let app = try Application(.detect())
defer { app.shutdown() }

- try app.run()
+ try Ginny.run(app: app)
```

From here on out, as long as the plugin is running, routes will be generated based on the way you have organized the files in your Vapor app's target. The way `Ginny` works is by looking inside your `.swift` files for `struct`s or `class`es that conform to either `RequestHandler` or `AsyncRequestHandler`.

For example, take the following file `api/hello.swift`:
```swift
import Foundation
import SwiftNext
import Vapor

struct HelloIndex: RequestHandler {

  var method: HTTPMethod {
    .GET
  }

  func handle(req: Request) throws -> String {
    "Hello, world!"
  }
}
```

Upon building your project, Ginny finds the `RequestHandler` inside of `/api/hello.swift` and generates the Vapor boilerplate under-the-hood to register your route. You can always see the exact code that Ginny generates by checking your target's build logs for `App.generated.swift` and `Routes.generated.swift`.

## Installation

1. Add Ginny as a dependency in your `Package.swift`:
```swift
package(url: "https://github.com/gonzalonunez/ginny", from: "0.1.0"),
```

2. In your Vapor app's executable, add the `Ginny` library as a dependency and the `GinnyPlugin` as a plugin. See `Sources/Example` for an example.
```swift
.executableTarget(
  name: "MyApp",
  dependencies: [
    .product(name: "Ginny", package: "Ginny"),
    .product(name: "Vapor", package: "Vapor"),
   ],
  plugins: [
    .plugin(name: "GinnyPlugin", package: "Ginny"),
   ]),
```

Now, Ginny will run any time that you build your project if any of your API routes have changed.
