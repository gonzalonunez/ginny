# Ginny 💧

![](https://github.com/gonzalonunez/ginny/actions/workflows/build.yml/badge.svg)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgonzalonunez%2Fginny%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/gonzalonunez/ginny)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgonzalonunez%2Fginny%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/gonzalonunez/ginny)

Ginny is a [Swift Package plugin](https://developer.apple.com/videos/play/wwdc2022/110359/) that enables file-based routing for [Vapor](https://vapor.codes) apps. It works by generating code at build-time that registers routes like you would in any normal Vapor app.

## Basic Usage

Ginny removes some of the boilerplate related to routing in Vapor apps while supporting the majority of its features. (For a list of unsupported features, see below.)

Using Ginny is as simple as a one-line change:

```diff
let app = try Application(.detect())
defer { app.shutdown() }

+ app.registerRoutes()
try app.run()
```

From here on out, as long as the plugin is running, routes will be generated based on the way you have organized the files in your Vapor app's target and what's inside of them.

The following folder structure:

```
pages/
├── api/
│   ├── hello.swift
│   ├── world
│   │   ├── world.index.swift
│   │   ├── foo.swift
```

Results in the following routes:

```
/api/hello
/api/world
/api/world/foo
```

`Ginny` looks inside your `/pages` directory for `.swift` files that contain conformances to either `RequestHandler` or `AsyncRequestHandler` and generates the rest of the route registration code for you.

For example, take the following file `/pages/api/hello.swift`:

```swift
import Foundation
import Ginny
import Vapor

struct Hello: RequestHandler {

  var method: HTTPMethod {
    .GET
  }

  func handle(req: Request) throws -> String {
    "Hello, world!"
  }
}
```

Each time that your project builds, Ginny finds the `RequestHandler` inside of `/pages/api/hello.swift` and generates the Vapor boilerplate under-the-hood to register your route. You can always see the exact code that Ginny generates by checking your target's build logs for `Routes.generated.swift`.

From here, you can run your server like you would normally and make a request to the corresponding endpoint:

```
curl -X GET http://localhost:8080/api/hello
```

## Installation

1. Add Ginny as a dependency in your `Package.swift`:

```swift
.package(url: "https://github.com/gonzalonunez/ginny.git", from: "0.1.1"),
```

2. In your Vapor app's executable, add the `Ginny` library as a dependency and the `GinnyPlugin` as a plugin. See the example app for more.

```swift
.executableTarget(
  name: "MyApp",
  dependencies: [
    .product(name: "Ginny", package: "ginny"),
    .product(name: "Vapor", package: "vapor"),
   ],
  plugins: [
    .plugin(name: "GinnyPlugin", package: "ginny"),
   ]),
```

Now, Ginny will run any time that you build your project if any of your API routes have changed.

## Gotchas

There are a few subtleties related to how Ginny generates code for you:

- Normally, in other systems, files named `index` are used to refer to the root of a directory. Unfortunately, this doesn't work in Swift because you can't have two files in the same module with the same name. Ginny works around this by dropping any path components that contain `.index`, whether that's a file or a folder. This allows you to prefix your `index` files with anything else you need to disambiguate them. So, `api/hello/hello.index.swift` is routed to `api/hello` and `api/hello/world/world.index.swift` is routed to `api/hello/world/`. See the example app for more.

- Ginny is smart enough to support two `RequestHandler`s in the same file, it will register both of them for you. So, you can declare multiple handlers in the same file with different HTTP methods and get the behavior that you would expect: `GET api/hello` and `POST api/hello`, for example.

- Ginny registers routes in alphabetic order according to the file system. You can always inspect `Routes.generated.swift` in your build logs to see the code that Ginny generates. If you'd like different behavior here, please file a GitHub issue.

## Feature parity with Vapor

Ginny supports most of Vapor's routing features at the moment. Support for missing features can be added if there's any appetite for them, please file a GitHub issue to get a discussion going!

#### Supported

- [x] [Route parameters](https://docs.vapor.codes/basics/routing/#route-parameters): Vapor's route parameters are supported with a `[]` syntax. For example, a file named `api/user/[id].swift` ends up getting registered with Vapor as `api/user/:id`

- [x] [Catchall parameters](https://docs.vapor.codes/basics/routing/#catchall): Vapor's catchall parameters are supported with a `...` syntax. For example, a file named `api/user/[...slug].swift` ends up getting registered with Vapor as `api/user/***` and allows you to later retrieve the catchall. The `slug` part does not matter, you can name that whatever you'd like (and you'll have to if you want to have multiple files in the same module that support catchall parameters because you can't have two files in the same Swift module with the same name)

- [x] [Route middleware](https://docs.vapor.codes/basics/routing/#route-groups): Vapor's route middlewares are supported by providing a `middlewares` array within your `RequestHandler` that will be additionally grouped with the app's current middlewares

#### Not yet supported

- [ ] [Anything parameters](https://docs.vapor.codes/basics/routing/#anything)
- [ ] [Route groups](https://docs.vapor.codes/basics/routing/#route-groups)
- [ ] [Metadata](https://docs.vapor.codes/basics/routing/#metadata)

## Inspiration

Ginny was inspired by the way [Vercel](https://vercel.com/home) does routing. I'm a big fan of all things Vercel and Next.js, I highly recommend taking a look.

## Why Ginny?

[Ginny Strazisar](https://www.ithistory.org/honor-roll/ms-ginny-strazisar) developed the [first true IP router](<https://en.wikipedia.org/wiki/Router_(computing)#cite_ref-26>) in 1975.
