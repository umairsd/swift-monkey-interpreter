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


  func testIdentifierExpression() throws {
    let input = "foobar;"
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)

    guard let program = parser.parseProgram() else {
      XCTFail("`parseProgram()` failed to parse the input.")
      return
    }
    checkParserErrors(parser)

    XCTAssertEqual(program.statements.count, 1)
    XCTAssertTrue(
      program.statements[0] is ExpressionStatement,
      "statement is not of the type `ExpressionStatement`.")

    let expressionStatement = program.statements[0] as! ExpressionStatement
    XCTAssertNotNil(expressionStatement.expression)

    XCTAssertTrue(
      expressionStatement.expression! is Identifier,
      "expressionStatement.expression is not of the type `Identifier`.")
    let expressionIdentifer = expressionStatement.expression! as! Identifier

    XCTAssertEqual(
      expressionIdentifer.value,
      "foobar",
      "expressionIdentifer.value not \("foobar"). Got=\(expressionIdentifer.value)")
    XCTAssertEqual(
      expressionIdentifer.tokenLiteral(),
      "foobar",
      "expressionIdentifer.tokenLiteral() not \("foobar"). Got=\(expressionIdentifer.tokenLiteral())")
  }


  func testIntegerLiteral() throws {
    let input = "5;"
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)

    guard let program = parser.parseProgram() else {
      XCTFail("`parseProgram()` failed to parse the input.")
      return
    }
    checkParserErrors(parser)

    XCTAssertEqual(program.statements.count, 1)
    XCTAssertTrue(
      program.statements[0] is ExpressionStatement,
      "statement is not of the type `ExpressionStatement`.")

    let expressionStatement = program.statements[0] as! ExpressionStatement
    XCTAssertNotNil(expressionStatement.expression)

    XCTAssertTrue(
      expressionStatement.expression! is IntegerLiteral,
      "expressionStatement.expression is not of the type `IntegerLiteral`.")
    let integerLiteral = expressionStatement.expression! as! IntegerLiteral

    XCTAssertEqual(
      integerLiteral.value,
      5,
      "integerLiteral.value not \(5). Got=\(integerLiteral.value)")
    XCTAssertEqual(
      integerLiteral.tokenLiteral(),
      "5",
      "integerLiteral.tokenLiteral() not \("5"). Got=\(integerLiteral.tokenLiteral())")
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
