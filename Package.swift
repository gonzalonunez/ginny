// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "SwiftNext",
  platforms: [.macOS(.v12)],
  products: [
    .executable(
      name: "Example",
      targets: ["Example"]),

    .executable(
      name: "SwiftNext",
      targets: ["SwiftNext"]),

    .plugin(
      name: "SwiftNextPlugin",
      targets: ["SwiftNextPlugin"]),
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.7.0"),
  ],
  targets: [
    .executableTarget(
      name: "Example",
      dependencies: [
        .product(name: "Vapor", package: "Vapor"),
      ],
      plugins: [
        .plugin(name: "SwiftNextPlugin"),
      ]),

    .executableTarget(
      name: "SwiftNext",
      dependencies: []),

    .plugin(
      name: "SwiftNextPlugin",
      capability: .buildTool(),
      dependencies: [
        "SwiftNext",
      ]),
  ]
)
