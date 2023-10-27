// Created on 10/27/23.

import XCTest
import Token
@testable import AST

final class ASTTest: XCTestCase {

  func testToString_letStatement() {

    let letStmt = LetStatement(
      token: Token(type: .let, literal: "let"),
      name: Identifier(token: Token(type: .ident, literal: "myVar"), value: "myVar"),
      value: Identifier(token: Token(type: .ident, literal: "anotherVar"), value: "anotherVar"))
    let program = Program(statements: [letStmt])

    XCTAssertEqual(program.toString(), "let myVar = anotherVar;\n")
  }


  func testToString_returnStatement() {
    // TODO: Add return expression to the tests for return statement.
    let returnStmt = ReturnStatement(
      token: Token(type: .return, literal: "return"))

    let letStmt = LetStatement(
      token: Token(type: .let, literal: "let"),
      name: Identifier(token: Token(type: .ident, literal: "myVar"), value: "myVar"),
      value: Identifier(token: Token(type: .ident, literal: "anotherVar"), value: "anotherVar"))
    let program = Program(statements: [letStmt, returnStmt])

    XCTAssertEqual(program.toString(), "let myVar = anotherVar;\nreturn;\n")
  }

}
