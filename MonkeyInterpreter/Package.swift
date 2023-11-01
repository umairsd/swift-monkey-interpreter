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
      name: "Evaluator",
      dependencies: ["AST", "Object", "Parser", "Token"]
    ),
    .target(
      name: "Lexer",
      dependencies: ["Token"]
    ),
    .target(
      name: "Parser",
      dependencies: ["Lexer", "AST"]
    ),
    .target(
      name: "Object",
      dependencies: ["AST"]
    ),
    .target(
      name: "Repl",
      dependencies: ["Lexer", "Object", "Parser", "Evaluator"]
    ),
    .target(
      name: "Token",
      dependencies: []
    ),
    // Test Targets
    .testTarget(
      name: "ASTTests",
      dependencies: ["AST", "Token"]
    ),
    .testTarget(
      name: "EvaluatorTests",
      dependencies: ["Evaluator", "Object", "Lexer", "Parser"]
    ),
    .testTarget(
      name: "LexerTests",
      dependencies: ["Lexer", "Token"]
    ),
    .testTarget(
      name: "ParserTests",
      dependencies: ["Lexer", "Parser"]
    )
  ]
)
