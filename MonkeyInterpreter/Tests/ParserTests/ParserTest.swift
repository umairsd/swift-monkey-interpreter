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
    checkParserErrors(parser)

    let expectedIdentifiers = ["x", "y", "foobar"]
    XCTAssertEqual(program.statements.count, 3)

    for (i, statement) in program.statements.enumerated() {
      let expectedIdentifierName = expectedIdentifiers[i]

      try validateLetStatement(statement, identifier: expectedIdentifierName)
    }
  }


  func testReturnStatement() throws {
    let input = """
    return 5;
    return 10;
    return 838383;
    """

    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)

    guard let program = parser.parseProgram() else {
      XCTFail("`parseProgram()` failed to parse the input.")
      return
    }
    checkParserErrors(parser)

    XCTAssertEqual(program.statements.count, 3)

    for statement in program.statements {
      XCTAssertEqual(
        statement.tokenLiteral(),
        "return",
        "statement.tokenLiteral() not `return`. Got=\(statement.tokenLiteral())")

      XCTAssertTrue(statement is ReturnStatement, "statement is not of the type `ReturnStatement`.")

      // let returnStatement = statement as! ReturnStatement
      // TODO: Validate the "return expression"
    }
  }


  // MARK: - Private

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

    // TODO: Validate the expression to the right of assignment.
    XCTAssertEqual(
      letStatement.name.value,
      name,
      "letStatement.name.value not \(name). Got=\(letStatement.name.value)")
  }


  private func checkParserErrors(_ parser: Parser) {
    if parser.errors.count > 0 {
      print("Parser has \(parser.errors.count) errors.")
      parser.errors.forEach { print($0) }
    }
  }
}
