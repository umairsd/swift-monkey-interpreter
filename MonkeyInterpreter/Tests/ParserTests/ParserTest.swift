// Created on 10/25/23.

import XCTest
import Lexer
import AST
@testable import Parser

final class ParserTest: XCTestCase {

  func testLetStatement() throws {
    let input = """
    let x = 5;
    let y = 10;
    let foobar = 838383;
    """

    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)

    guard let program = parser.parseProgram() else {
      XCTFail("`parseProgram()` failed to parse the input.")
      return
    }

    let expectedIdentifiers = ["x", "y", "foobar"]
    XCTAssertEqual(program.statements.count, 3)

    for (i, statement) in program.statements.enumerated() {
      let expectedIdentifierName = expectedIdentifiers[i]

      try validateLetStatement(statement, identifier: expectedIdentifierName)
    }
  }


  private func validateLetStatement(_ statement: Statement, identifier name: String) throws {
    XCTAssertEqual(
      statement.tokenLiteral(),
      "let",
      "statement.tokenLiteral() not `let`. Got=\(statement.tokenLiteral())")
    
    XCTAssertTrue(statement is LetStatement, "statement is not of the type `LetStatement`.")

    let letStatement = statement as! LetStatement
    
    XCTAssertEqual(
      letStatement.name.tokenLiteral(),
      name,
      "letStatement.name.tokenLiteral() not \(name). Got=\(letStatement.name.tokenLiteral())")

    XCTAssertEqual(
      letStatement.name.value,
      name,
      "letStatement.name.value not \(name). Got=\(letStatement.name.value)")
  }
}
