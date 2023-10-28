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

    XCTAssertEqual(program.toString(), "let myVar = anotherVar;")
  }


  func testToString_returnStatement() {
    let returnStmt = ReturnStatement(
      token: Token(type: .return, literal: "return"))

    let letStmt = LetStatement(
      token: Token(type: .let, literal: "let"),
      name: Identifier(token: Token(type: .ident, literal: "myVar"), value: "myVar"),
      value: Identifier(token: Token(type: .ident, literal: "anotherVar"), value: "anotherVar"))
    let program = Program(statements: [letStmt, returnStmt])

    XCTAssertEqual(
      program.toString(),
      """
      let myVar = anotherVar;
      return;
      """)
  }


  func testToString_returnStatementWithExpr() {
    let returnStmt1 = ReturnStatement(
      token: Token(type: .return, literal: "return 5"))

    let returnStmt2 = ReturnStatement(
      token: Token(type: .return, literal: "return myVar"))

    let program = Program(statements: [returnStmt1, returnStmt2])

    XCTAssertEqual(
      program.toString(),
      """
      return 5;
      return myVar;
      """)
  }
}
