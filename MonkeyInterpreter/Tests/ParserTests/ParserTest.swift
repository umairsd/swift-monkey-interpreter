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

    try validateIntegerLiteral(expressionStatement.expression!, expectedValue: 5)
  }


  func testPrefixExpression() throws {
    try validatePrefixExpression("!5", expectedOperator: "!", integerValue: 5)
    try validatePrefixExpression("-27", expectedOperator: "-", integerValue: 27)
  }


  func testInfixExpression() throws {
    let tests: [(input: String, leftValue: Any, expectedOperator: String, rightValue: Any)] = [
      ("5 + 5", 5, "+", 5),
      ("5 - 5", 5, "-", 5),
      ("5 * 5", 5, "*", 5),
      ("5 / 5", 5, "/", 5),
      ("5 > 5", 5, ">", 5),
      ("5 < 5", 5, "<", 5),
      ("5 == 5", 5, "==", 5),
      ("5 != 5", 5, "!=", 5),
      ("alice * bob", "alice", "*", "bob"),
    ]

    for testCase in tests {
      let lexer = Lexer(input: testCase.input)
      let parser = Parser(lexer: lexer)

      guard let program = parser.parseProgram() else {
        XCTFail("`parseProgram()` failed to parse the input.")
        return
      }
      if checkParserErrors(parser) {
        XCTFail("Test failed due to preceding parser errors.")
        return
      }
      
      XCTAssertEqual(program.statements.count, 1)
      guard let expressionStatement = program.statements[0] as? ExpressionStatement else {
        XCTFail("Statement is not of type `ExpressionStatement`.")
        return
      }

      guard let expression = expressionStatement.expression else {
        XCTFail("expressionStatement.expression is nil.")
        return
      }

      try validateInfixExpression(
        expression,
        leftValue: testCase.leftValue,
        operator: testCase.expectedOperator,
        rightValue: testCase.rightValue)
    }
  }


  func testBoolean() throws {
    let tests: [(input: String, expectedValue: Bool)] = [
      ("true", true),
      ("false", false)
    ]

    for testCase in tests {
      let lexer = Lexer(input: testCase.input)
      let parser = Parser(lexer: lexer)

      guard let program = parser.parseProgram() else {
        XCTFail("`parseProgram()` failed to parse the input.")
        return
      }
      if checkParserErrors(parser) {
        XCTFail("Test failed due to preceding parser errors.")
        return
      }

      XCTAssertEqual(program.statements.count, 1)
      XCTAssertTrue(
        program.statements[0] is ExpressionStatement,
        "statement is not of the type `ExpressionStatement`.")

      let expressionStatement = program.statements[0] as! ExpressionStatement
      XCTAssertNotNil(expressionStatement.expression)

      XCTAssertTrue(
        expressionStatement.expression! is Boolean,
        "expressionStatement.expression is not of the type `Boolean`.")
      let boolean = expressionStatement.expression! as! Boolean

      XCTAssertEqual(
        boolean.value,
        testCase.expectedValue,
        "boolean.value not \(testCase.expectedValue). Got=\(boolean.value)")
    }
  }


  // MARK: - Stringly Tests

  func testInfixExpressions_Stringly() throws {
    let tests: [(input: String, expected: String)] = [
      ("-a * b", "((-a) * b)"),
      ("!-a", "(!(-a))"),
      ("a + b + c", "((a + b) + c)"),
      ("a + b - c", "((a + b) - c)"),
      ("a * b * c", "((a * b) * c)"),
      ("a * b / c", "((a * b) / c)"),
      ("a + b / c", "(a + (b / c))"),
      ("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"),
      ("3 + 4; -5 * 5", """
                        (3 + 4)
                        ((-5) * 5)
                        """),
      ("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"),
      ("5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"),
      ("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"),
    ]

    for testCase in tests {
      let lexer = Lexer(input: testCase.input)
      let parser = Parser(lexer: lexer)

      guard let program = parser.parseProgram() else {
        XCTFail("`parseProgram()` failed to parse the input.")
        return
      }
      let actual = program.toString()
      XCTAssertEqual(actual, testCase.expected)
    }
  }
  

  func testOperatorPrecedenceParsing() throws {
    let tests: [(input: String, expected: String)] = [
      ("true", "true"),
      ("false", "false"),
      ("3 > 5 == false", "((3 > 5) == false)"),
      ("3 < 5 == true", "((3 < 5) == true)"),
    ]
    for testCase in tests {
      let lexer = Lexer(input: testCase.input)
      let parser = Parser(lexer: lexer)

      guard let program = parser.parseProgram() else {
        XCTFail("`parseProgram()` failed to parse the input.")
        return
      }
      let actual = program.toString()
      XCTAssertEqual(actual, testCase.expected)
    }
  }


  // MARK: - Private


  private func validateInfixExpression(
    _ expression: Expression,
    leftValue: Any,
    operator: String,
    rightValue: Any
  ) throws {

    guard let infixExpr = expression as? InfixExpression else {
      XCTFail("Expression is not \(InfixExpression.self). Got=\(type(of: expression))")
      return
    }

    do {
      try validateLiteralExpression(infixExpr.leftExpression, expected: leftValue)
    } catch {
      XCTFail("Unable to validate the left part of the infix expression.")
    }

    XCTAssertEqual(infixExpr.infixOperator, `operator` )

    do {
      try validateLiteralExpression(infixExpr.rightExpression, expected: rightValue)
    } catch {
      XCTFail("Unable to validate the right part of the infix expression.")
    }
  }


  private func validatePrefixExpression(
    _ input: String,
    expectedOperator: String,
    integerValue: Int
  ) throws {

    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)

    guard let program = parser.parseProgram() else {
      XCTFail("`parseProgram()` failed to parse the input.")
      return
    }
    if checkParserErrors(parser) {
      XCTFail("Test failed due to preceding parser errors.")
      return
    }

    XCTAssertEqual(program.statements.count, 1)
    XCTAssertTrue(
      program.statements[0] is ExpressionStatement,
      "statement is not of the type `ExpressionStatement`.")

    let expressionStatement = program.statements[0] as! ExpressionStatement
    XCTAssertNotNil(expressionStatement.expression)

    XCTAssertTrue(
      expressionStatement.expression! is PrefixExpression,
      "expressionStatement.expression is not of the type `PrefixExpression`.")
    let prefixExpression = expressionStatement.expression! as! PrefixExpression

    XCTAssertEqual(
      prefixExpression.prefixOperator,
      expectedOperator,
      "prefixExpression.operator not \(expectedOperator). Got=\(prefixExpression.prefixOperator)")

    try validateIntegerLiteral(prefixExpression.rightExpression, expectedValue: integerValue)
  }


  /// Validates that the given expression is an `IntegerLiteral`, with the given value.
  private func validateIntegerLiteral(_ expression: Expression, expectedValue: Int) throws {
    XCTAssertTrue(
      expression is IntegerLiteral,
      "expression is not of the type `IntegerLiteral`.")
    let integerLiteral = expression as! IntegerLiteral

    XCTAssertEqual(
      integerLiteral.value,
      expectedValue,
      "integerLiteral.value not \(expectedValue). Got=\(integerLiteral.value)")

    XCTAssertEqual(
      integerLiteral.tokenLiteral(),
      "\(expectedValue)",
      "integerLiteral.tokenLiteral() not \(expectedValue). Got=\(integerLiteral.tokenLiteral())")
  }


  /// Validates that the given expression is an `Identifer`, with the given value.
  private func validateIdentifier(_ expression: Expression, expectedValue: String) throws {
    XCTAssertTrue(
      expression is Identifier,
      "expression is not of the type `Identifier`.")
    let identifer = expression as! Identifier

    XCTAssertEqual(
      identifer.value,
      expectedValue,
      "integerLiteral.value not \(expectedValue). Got=\(identifer.value)")

    XCTAssertEqual(
      identifer.tokenLiteral(),
      "\(expectedValue)",
      "identifer.tokenLiteral() not \(expectedValue). Got=\(identifer.tokenLiteral())")
  }


  private func validateLiteralExpression(_ expression: Expression, expected: Any) throws {
    switch(expected) {
    case let v as Int:
      try validateIntegerLiteral(expression, expectedValue: v)

    case let v as String:
      try validateIdentifier(expression, expectedValue: v)

    default:
      XCTFail("Unsupported type.")
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

    // TODO: Validate the expression to the right of assignment.
    XCTAssertEqual(
      letStatement.name.value,
      name,
      "letStatement.name.value not \(name). Got=\(letStatement.name.value)")
  }


  @discardableResult
  private func checkParserErrors(_ parser: Parser) -> Bool {
    if parser.errors.count > 0 {
      print("Parser has \(parser.errors.count) errors.")
      parser.errors.forEach { print($0) }
      return true
    }
    return false
  }
}
