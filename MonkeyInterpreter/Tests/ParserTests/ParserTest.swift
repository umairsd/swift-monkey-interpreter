// Created on 10/25/23.

import XCTest
import Lexer
import AST
@testable import Parser

final class ParserTest: XCTestCase {

  // MARK: - Statements

  func testLetStatement() throws {
    let tests: [(input: String, expectedIdentifier: String, expectedValue: Any)] = [
      ("let x = 5;", "x", 5),
      ("let z = true;", "z", true),
      ("let foobar = bar;", "foobar", "bar"),
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

      guard let letStmt = program.statements.first as? LetStatement else {
        XCTFail("statement is not of type `LetStatement`")
        return
      }

      try validateLetStatement(letStmt, identifier: testCase.expectedIdentifier)

      try validateLiteralExpression(letStmt.value, expected: testCase.expectedValue)
    }
  }


  func testReturnStatement() throws {
    let tests: [(input: String, expectedValue: Any?)] = [
      ("return;", nil),
      ("return 5;", 5),
      ("return tin;", "tin"),
      ("return false;", false)
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

      try validateReturnStatement(program.statements[0], expectedValue: testCase.expectedValue)
    }
  }


  // MARK: - Literals

  func testIntegerLiteral() throws {
    let input = "5;"
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

    guard let expressionStmt = program.statements.first as? ExpressionStatement else {
      XCTFail("statement is not of the type `ExpressionStatement`.")
      return
    }
    guard let expression = expressionStmt.expression as? IntegerLiteral else {
      XCTFail("expressionStatement.expression is not of the type `IntegerLiteral`.")
      return
    }

    try validateIntegerLiteral(expression, expectedValue: 5)
  }


  func testStringLiteral() throws {
    let tests: [(input: String, expectedValue: String)] = [
      ("\"foobar\"", "foobar"),
      ("\"foo bar\"", "foo bar"),
      ("\"foo bar         \"", "foo bar         "),
      ("\"12320\"", "12320"),
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

      guard let expressionStmt = program.statements.first as? ExpressionStatement else {
        XCTFail("statement is not of the type `ExpressionStatement`.")
        return
      }
      guard let str = expressionStmt.expression as? StringLiteral else {
        XCTFail("expressionStatement.expression is not of the type `StringLiteral`.")
        return
      }

      XCTAssertEqual(
        str.value,
        testCase.expectedValue,
        "string.value not \(testCase.expectedValue). Got=\(str.value)")
    }
  }


  func testBooleanLiteral() throws {
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

      guard let expressionStmt = program.statements.first as? ExpressionStatement else {
        XCTFail("statement is not of the type `ExpressionStatement`.")
        return
      }
      guard let boolean = expressionStmt.expression as? BooleanLiteral else {
        XCTFail("expressionStatement.expression is not of the type `Boolean`.")
        return
      }

      XCTAssertEqual(
        boolean.value,
        testCase.expectedValue,
        "boolean.value not \(testCase.expectedValue). Got=\(boolean.value)")
    }
  }


  // MARK: - Expressions


  func testIdentifierExpression() throws {
    let input = "foobar;"
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

    guard let expressionStmt = program.statements.first as? ExpressionStatement else {
      XCTFail("statement is not of the type `ExpressionStatement`.")
      return
    }
    guard let expressionIdentifer = expressionStmt.expression as? Identifier else {
      XCTFail("expressionStatement.expression is not of the type `Identifier`.")
      return
    }

    XCTAssertEqual(
      expressionIdentifer.value,
      "foobar",
      "expressionIdentifer.value not \("foobar"). Got=\(expressionIdentifer.value)")
    XCTAssertEqual(
      expressionIdentifer.tokenLiteral(),
      "foobar",
      "expressionIdentifer.tokenLiteral() not \("foobar"). Got=\(expressionIdentifer.tokenLiteral())")
  }


  func testPrefixExpression() throws {
    let tests: [(input: String, expectedOperator: String, expectedValue: Any)] = [
      ("!5", "!", 5),
      ("-27", "-", 27),
      ("!true", "!", true),
      ("!false", "!", false),
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

      guard let expressionStmt = program.statements.first as? ExpressionStatement else {
        XCTFail("statement is not of the type `ExpressionStatement`.")
        return
      }
      guard let prefixExpression = expressionStmt.expression else {
        XCTFail("expressionStatement.expression is nil.")
        return
      }

      try validatePrefixExpression(
        prefixExpression,
        expectedOperator: testCase.expectedOperator,
        expectedValue: testCase.expectedValue)
    }
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
      
      ("true == true", true, "==", true),
      ("true != false", true, "!=", false),
      ("false == false", false, "==", false),
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

      guard let expressionStmt = program.statements.first as? ExpressionStatement else {
        XCTFail("statement is not of the type `ExpressionStatement`.")
        return
      }
      guard let infixExpression = expressionStmt.expression else {
        XCTFail("expressionStatement.expression is nil.")
        return
      }

      try validateInfixExpression(
        infixExpression,
        leftValue: testCase.leftValue,
        operator: testCase.expectedOperator,
        rightValue: testCase.rightValue)
    }
  }


  func testIfExpression() throws {
    let input = "if (x < y) { x }"


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

    guard let expressionStmt = program.statements.first as? ExpressionStatement else {
      XCTFail("statement is not of the type `ExpressionStatement`.")
      return
    }
    guard let ifExpr = expressionStmt.expression as? IfExpression else {
      XCTFail("expressionStatement.expression is not of the type `IfExpression`.")
      return
    }

    try validateInfixExpression(ifExpr.condition, leftValue: "x", operator: "<", rightValue: "y")

    XCTAssertEqual(ifExpr.consequence.statements.count, 1)

    guard let consequenceStmt = ifExpr.consequence.statements[0] as? ExpressionStatement,
          let consequenceExpr = consequenceStmt.expression
    else {
      XCTFail("consequence.statements[0] is not `ExpressionStatement`.")
      return
    }

    try validateIdentifier(consequenceExpr, expectedValue: "x")

    XCTAssertNil(ifExpr.alternative, "ifExpression.alternative is not nil.")
  }


  func testIfExpression2_bodyStatements() throws {
    let input = "if (x < y) { let z = x + 1; let w = z * 5; return w; }"
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)

    guard let program = parser.parseProgram(), !checkParserErrors(parser) else {
      XCTFail("Test failed due to preceding parser errors.")
      return
    }

    guard let expressionStmt = program.statements.first as? ExpressionStatement,
          let ifExpr = expressionStmt.expression as? IfExpression
    else {
      XCTFail("statement is not of the type `ExpressionStatement`.")
      return
    }

    try validateInfixExpression(ifExpr.condition, leftValue: "x", operator: "<", rightValue: "y")

    XCTAssertEqual(ifExpr.consequence.statements.count, 3)

    // If Body
    try validateLetStatement(ifExpr.consequence.statements[0], identifier: "z")
    try validateLetStatement(ifExpr.consequence.statements[1], identifier: "w")
    try validateReturnStatement(ifExpr.consequence.statements[2], expectedValue: "w")
  }


  func testIfElseExpression() throws {
    let input = "if (x < y) { x } else { y }"
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)

    guard let program = parser.parseProgram() else {
      XCTFail("`parseProgram()` failed to parse the input.")
      return
    }
    guard !checkParserErrors(parser) else {
      XCTFail("Test failed due to preceding parser errors.")
      return
    }


    XCTAssertEqual(program.statements.count, 1)

    guard let expressionStmt = program.statements.first as? ExpressionStatement else {
      XCTFail("statement is not of the type `ExpressionStatement`.")
      return
    }
    guard let ifExpr = expressionStmt.expression as? IfExpression else {
      XCTFail("expressionStatement.expression is not of the type `IfExpression`.")
      return
    }

    try validateInfixExpression(ifExpr.condition, leftValue: "x", operator: "<", rightValue: "y")

    XCTAssertEqual(ifExpr.consequence.statements.count, 1)

    guard let consequenceStmt = ifExpr.consequence.statements[0] as? ExpressionStatement,
          let consequenceExpr = consequenceStmt.expression
    else {
      XCTFail("consequence.statements[0] is not `ExpressionStatement`.")
      return
    }

    try validateIdentifier(consequenceExpr, expectedValue: "x")

    guard let alternativeStmt = ifExpr.alternative?.statements[0] as? ExpressionStatement,
          let alternativeExpr = alternativeStmt.expression
    else {
      XCTFail("alternative.statements[0] is not `ExpressionStatement`.")
      return
    }

    try validateIdentifier(alternativeExpr, expectedValue: "y")
  }


  func testFunctionLiteralParsing() throws {
    struct BodyStmt {
      let leftValue: Any
      let expectedOperator: String
      let rightValue: Any
      init(_ l: Any, _ o: String, _ r: Any) {
        leftValue = l
        expectedOperator = o
        rightValue = r
      }
    }

    let tests: [(input: String, expectedParams: [String], bodyStmts: [BodyStmt])] = [
      ("fn() {};", [], []),
      ("fn(x) {};", ["x"], []),
      ("fn(x, y, z) {};", ["x", "y", "z"], []),
      ("fn(x, y, z) { x + y; 5 * z; };", ["x", "y", "z"], [BodyStmt("x", "+", "y"),
                                                           BodyStmt(5, "*", "z")]),
    ]

    for testCase in tests {
      let lexer = Lexer(input: testCase.input)
      let parser = Parser(lexer: lexer)
      guard let program = parser.parseProgram() else {
        XCTFail("`parseProgram()` failed to parse the input.")
        return
      }
      guard !checkParserErrors(parser) else {
        XCTFail("Test failed due to preceding parser errors.")
        return
      }

      XCTAssertEqual(program.statements.count, 1)

      guard let expressionStmt = program.statements.first as? ExpressionStatement else {
        XCTFail("statement is not of the type `ExpressionStatement`.")
        return
      }
      guard let fnExpr = expressionStmt.expression as? FunctionLiteral else {
        XCTFail("expressionStatement.expression is not of the type `FunctionLiteral`.")
        return
      }

      XCTAssertEqual(
        fnExpr.parameters.count,
        testCase.expectedParams.count,
        """
        fnExpr.parameter.count is not equal to \(testCase.expectedParams.count).\
        Got=\(fnExpr.parameters.count)
        """)

      // Validate the parameters.
      for (i, p) in fnExpr.parameters.enumerated() {
        try validateLiteralExpression(p, expected: testCase.expectedParams[i])
      }

      XCTAssertEqual(
        fnExpr.body.statements.count,
        testCase.bodyStmts.count,
        """
        fnExpr.body.statements.count is not equal to \(testCase.bodyStmts.count). \
        Got=\(fnExpr.body.statements.count)
        """)

      // Validate the statements in teh body.
      for (i, statement) in fnExpr.body.statements.enumerated() {
        guard let bodyStmt = statement as? ExpressionStatement,
              let bodyExpr = bodyStmt.expression
        else {
          XCTFail("fnExpr.body.statements[\(i)] is not an `Expression`.")
          return
        }

        try validateInfixExpression(
          bodyExpr,
          leftValue: testCase.bodyStmts[i].leftValue,
          operator: testCase.bodyStmts[i].expectedOperator,
          rightValue: testCase.bodyStmts[i].rightValue)
      }
    }
  }


  func testCallExpression() throws {
    struct BodyStmt {
      let leftValue: Any
      let expectedOperator: String
      let rightValue: Any
      init(_ l: Any, _ o: String, _ r: Any) {
        leftValue = l
        expectedOperator = o
        rightValue = r
      }
    }
    enum CallTestArgument {
      case int(Int)
      case str(String)
      case infix(BodyStmt)
    }

    let tests: [(input: String, fnName: String, arguments: [CallTestArgument])] = [
      ("add(1, 2 * 3, 4 + 5);", "add", [.int(1),
                                        .infix(BodyStmt(2, "*", 3)),
                                        .infix(BodyStmt(4, "+", 5))]),
      ("sub(1);", "sub", [.int(1)]),
      ("add(1, foobar);", "add", [.int(1), .str("foobar")]),
    ]

    for testCase in tests {
      let lexer = Lexer(input: testCase.input)
      let parser = Parser(lexer: lexer)
      guard let program = parser.parseProgram() else {
        XCTFail("`parseProgram()` failed to parse the input.")
        return
      }
      guard !checkParserErrors(parser) else {
        XCTFail("Test failed due to preceding parser errors.")
        return
      }

      XCTAssertEqual(program.statements.count, 1)

      guard let expressionStmt = program.statements.first as? ExpressionStatement else {
        XCTFail("statement is not of the type `ExpressionStatement`.")
        return
      }
      guard let callExpr = expressionStmt.expression as? CallExpression else {
        XCTFail("expressionStatement.expression is not of the type `CallExpression`.")
        return
      }

      XCTAssertEqual(
        callExpr.function.tokenLiteral(),
        testCase.fnName,
        "Parsed function name is not \(testCase.fnName). Got=\(callExpr.function.tokenLiteral())"
      )

      XCTAssertEqual(
        callExpr.arguments.count,
        testCase.arguments.count,
        """
        callExpr.arguments.count is not equal to \(testCase.arguments.count).\
        Got=\(callExpr.arguments.count)
        """)


      for (i, arg) in testCase.arguments.enumerated() {
        switch arg {
        case .int(let integerLiteral):
          try validateIntegerLiteral(callExpr.arguments[i], expectedValue: integerLiteral)

        case .str(let s):
          try validateIdentifier(callExpr.arguments[i], expectedValue: s)

        case .infix(let bodyStmt):
          try validateInfixExpression(
            callExpr.arguments[i],
            leftValue: bodyStmt.leftValue,
            operator: bodyStmt.expectedOperator,
            rightValue: bodyStmt.rightValue)
        }
      }
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
      ("1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"),
      ("(5 + 5) * 2", "((5 + 5) * 2)"),
      ("2 / (5 + 5)", "(2 / (5 + 5))"),
      ("-(5 + 5)", "(-(5 + 5))"),
      ("!(true == true)", "(!(true == true))"),
      ("a + add(b * c) + d", "((a + add((b * c))) + d)"),
      ("add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"),
      ("add(a + b + c * d / f + g)", "add((((a + b) + ((c * d) / f)) + g))")
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
    _ expression: Expression,
    expectedOperator: String,
    expectedValue: Any
  ) throws {

    guard let prefixExpression = expression as? PrefixExpression else {
      XCTFail("Expression is not \(PrefixExpression.self). Got=\(type(of: expression))")
      return
    }

    XCTAssertEqual(
      prefixExpression.prefixOperator,
      expectedOperator,
      "prefixExpression.operator not \(expectedOperator). Got=\(prefixExpression.prefixOperator)")

    try validateLiteralExpression(prefixExpression.rightExpression, expected: expectedValue)
  }


  private func validateLiteralExpression(_ expression: Expression, expected: Any) throws {
    switch(expected) {
    case let v as Int:
      try validateIntegerLiteral(expression, expectedValue: v)

    case let s as String:
      try validateIdentifier(expression, expectedValue: s)

    case let b as Bool:
      try validateBooleanLiteral(expression, expectedValue: b)

    default:
      XCTFail("Unsupported type.")
    }
  }


  /// Validates that the given expression is a `Boolean`, with the given value.
  private func validateBooleanLiteral(_ expression: Expression, expectedValue: Bool) throws {
    guard let booleanLiteral = expression as? BooleanLiteral else {
      XCTFail("expression is not of the type `Boolean`.")
      return
    }

    XCTAssertEqual(
      booleanLiteral.value,
      expectedValue,
      "booleanLiteral.value not \(expectedValue). Got=\(booleanLiteral.value)")

    XCTAssertEqual(
      booleanLiteral.tokenLiteral(),
      "\(expectedValue)",
      "booleanLiteral.tokenLiteral() not \(expectedValue). Got=\(booleanLiteral.tokenLiteral())")
  }


  /// Validates that the given expression is an `IntegerLiteral`, with the given value.
  private func validateIntegerLiteral(_ expression: Expression, expectedValue: Int) throws {
    guard let integerLiteral = expression as? IntegerLiteral else {
      XCTFail("expression is not of the type `IntegerLiteral`.")
      return
    }

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
    guard let identifer = expression as? Identifier else {
      XCTFail("expression is not of the type `Identifier`.")
      return
    }

    XCTAssertEqual(
      identifer.value,
      expectedValue,
      "integerLiteral.value not \(expectedValue). Got=\(identifer.value)")

    XCTAssertEqual(
      identifer.tokenLiteral(),
      "\(expectedValue)",
      "identifer.tokenLiteral() not \(expectedValue). Got=\(identifer.tokenLiteral())")
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


  private func validateReturnStatement(_ statement: Statement, expectedValue: Any?) throws {
    guard let returnStmt = statement as? ReturnStatement else {
      XCTFail("statement is not of type `ReturnStatement`")
      return
    }

    XCTAssertEqual(
      returnStmt.tokenLiteral(),
      "return",
      "statement.tokenLiteral() not `return`. Got=\(returnStmt.tokenLiteral())")

    if let expectedValue = expectedValue, let actualValue = returnStmt.returnValue {
      try validateLiteralExpression(actualValue, expected: expectedValue)
    } else if let actualValue = returnStmt.returnValue {
      XCTFail("Got a return value of \(actualValue.toString()), even though nil expected.")
    } else {
      XCTAssertNil(returnStmt.returnValue, "returnValue must be nil.")
    }
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
