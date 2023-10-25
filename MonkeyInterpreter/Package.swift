// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MonkeyInterpreter",
  products: [
    .executable(name: "monkey", targets: ["MonkeyInterpreter"])
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .executableTarget(
      name: "MonkeyInterpreter",
      dependencies: ["Repl"]
    ),
    .target(
      name: "AST",
      dependencies: ["Token"]
    ),
    .target(
      name: "Lexer",
      dependencies: ["Token"]
    ),
    .target(
      name: "Repl",
      dependencies: ["Lexer"]
    ),
    .target(
      name: "Token",
      dependencies: []
    ),
    // Test Targets
    .testTarget(
      name: "LexerTests",
      dependencies: ["Lexer", "Token"]
    )
  ]
)