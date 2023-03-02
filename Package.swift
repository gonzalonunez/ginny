// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "Ginny",
  platforms: [.macOS(.v12)],
  products: [
    .executable(
      name: "Example",
      targets: ["Example"]),

    .library(
      name: "Ginny",
      targets: ["Ginny"]),

    .executable(
      name: "GinnyCLI",
      targets: ["GinnyCLI"]),

    .plugin(
      name: "GinnyPlugin",
      targets: ["GinnyPlugin"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax", revision: "cd772d1"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.7.0"),
  ],
  targets: [
    .executableTarget(
      name: "Example",
      dependencies: [
        "Ginny",
        .product(name: "Vapor", package: "Vapor"),
      ],
      plugins: [
        .plugin(name: "GinnyPlugin"),
      ]),

    .testTarget(
      name: "ExampleTests",
      dependencies: [
        "Example",
      ]),

    .target(
      name: "Ginny",
      dependencies: [
        .product(name: "Vapor", package: "Vapor"),
      ]),

    .testTarget(
      name: "GinnyTests",
      dependencies: [
        "Ginny",
      ]),

    .executableTarget(
      name: "GinnyCLI",
      dependencies: [
        .product(name: "SwiftParser", package: "swift-syntax"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "Vapor", package: "Vapor"),
      ]),

    .plugin(
      name: "GinnyPlugin",
      capability: .buildTool(),
      dependencies: [
        "GinnyCLI",
      ]),
  ]
)
