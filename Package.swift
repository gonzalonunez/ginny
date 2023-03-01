// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "SwiftNext",
  platforms: [.macOS(.v12)],
  products: [
    .executable(
      name: "Example",
      targets: ["Example"]),

    .library(
      name: "SwiftNext",
      targets: ["SwiftNext"]),

    .executable(
      name: "SwiftNextCLI",
      targets: ["SwiftNextCLI"]),

    .plugin(
      name: "SwiftNextPlugin",
      targets: ["SwiftNextPlugin"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax", revision: "cd772d1"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.7.0"),
  ],
  targets: [
    .executableTarget(
      name: "Example",
      dependencies: [
        "SwiftNext",
        .product(name: "Vapor", package: "Vapor"),
      ],
      plugins: [
        .plugin(name: "SwiftNextPlugin"),
      ]),

    .target(
      name: "SwiftNext",
      dependencies: [
        .product(name: "Vapor", package: "Vapor"),
      ]),

    .executableTarget(
      name: "SwiftNextCLI",
      dependencies: [
        .product(name: "SwiftParser", package: "swift-syntax"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "Vapor", package: "Vapor"),
      ]),

    .plugin(
      name: "SwiftNextPlugin",
      capability: .buildTool(),
      dependencies: [
        "SwiftNextCLI",
      ]),
  ]
)
