// Created on 10/31/23.

import XCTest
import Lexer
import Object
import Parser
@testable import Evaluator

final class EvaluatorTest: XCTestCase {


  func testRepl() throws {
    let tests: [(input: String, expected: Int)] = [
      ("""
      let a = 5;
      let c = a * 99;
      let d = if (c > a) { 99 } else { 100 };
      return d;
      """, 
       99),

      ("""
      let add = fn(a, b) { a + b };
      let sub = fn(a, b) { a - b };
      let applyFunc = fn(a, b, func) { func(a, b) };
      applyFunc(2, 2, add);
      """,
      4),

      ("""
      let add = fn(a, b) { a + b };
      let sub = fn(a, b) { a - b };
      let applyFunc = fn(a, b, func) { func(a, b) };
      applyFunc(10, 2, sub);
      """,
      8)
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)
      if let errorObj = evaluated as? ErrorObject {
        XCTFail(errorObj.message)
        return
      }

      try validateIntegerObject(evaluated, expected: testCase.expected)
    }
  }


  func testEvalIntegerExpression() throws {
    let tests: [(input: String, expected: Int)] = [
      ("5", 5),
      ("128", 128),
      ("-7", -7),
      ("-10", -10),
      ("5 + 5 + 5 + 5 - 10", 10),
      ("2 * 2 * 2 * 2 * 2", 32),
      ("-50 + 100 + -50", 0),
      ("5 * 2 + 10", 20),
      ("5 + 2 * 10", 25),
      ("20 + 2 * -10", 0),
      ("50 / 2 * 2 + 10", 60),
      ("2 * (5 + 10)", 30),
      ("3 * 3 * 3 + 10", 37),
      ("3 * (3 * 3) + 10", 37),
      ("(5 + 10 * 2 + 15 / 3) * 2 + -10", 50),
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)
      if let errorObj = evaluated as? ErrorObject {
        XCTFail(errorObj.message)
        return
      }

      try validateIntegerObject(evaluated, expected: testCase.expected)
    }
  }


  func testEvalBooleanLiteral() throws {
    let tests: [(input: String, expected: Bool)] = [
      ("true", true),
      ("false", false),
      ("1 < 2", true),
      ("1 > 2", false),
      ("1 < 1", false),
      ("1 > 1", false),
      ("1 == 1", true),
      ("1 != 1", false),
      ("1 == 2", false),
      ("1 != 2", true),
      ("true == true", true),
      ("false == false", true),
      ("true == false", false),
      ("true != false", true),
      ("false != true", true),
      ("(1 < 2) == true", true),
      ("(1 < 2) == false", false),
      ("(1 > 2) == true", false),
      ("(1 > 2) == false", true),
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)
      if let errorObj = evaluated as? ErrorObject {
        XCTFail(errorObj.message)
        return
      }

      try validateBooleanObject(evaluated, expected: testCase.expected)
    }
  }


  func testEvalStringLiteral() throws {
    let tests: [(input: String, expectedValue: String)] = [
      ("\"foobar\"", "foobar"),
      ("\"foo bar\"", "foo bar"),
      ("\"foo bar         \"", "foo bar         "),
      ("\"12320\"", "12320"),
      ("\"hello, \" + \"world!\"", "hello, world!"),
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)
      if let errorObj = evaluated as? ErrorObject {
        XCTFail(errorObj.message)
        return
      }

      XCTAssertEqual(evaluated.inspect(), testCase.expectedValue)
    }
  }


  func testBangOperator() throws {
    let tests: [(input: String, expected: Bool)] = [
      ("!true", false),
      ("!false", true),
      ("!!false", false),
      ("!!true", true),
      ("!5", false),
      ("!!5", true),
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)
      if let errorObj = evaluated as? ErrorObject {
        XCTFail(errorObj.message)
        return
      }

      try validateBooleanObject(evaluated, expected: testCase.expected)
    }
  }


  func testIfElseExpression() throws {
    let tests: [(input: String, expected: Any?)] = [
      ("if (true) { 10 }", 10),
      ("if (false) { 10 }", nil),
      ("if (1) { 10 }", 10),
      ("if (1 < 2) { 10 }", 10),
      ("if (1 > 2) { 10 }", nil),
      ("if (1 > 2) { 10 } else { 20 }", 20),
      ("if (1 < 2) { 10 } else { 20 }", 10),
      ("if (5 * 5 + 10 > 34) { 99 } else { 100 }", 99),
      ("if ((1000 / 2) + 250 * 2 == 1000) { 9999 }", 9999),
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)
      if let errorObj = evaluated as? ErrorObject {
        XCTFail(errorObj.message)
        return
      }

      switch testCase.expected {
      case let expectedInt as Int:
        try validateIntegerObject(evaluated, expected: expectedInt)
      default:
        try validateNullObject(evaluated)
      }
    }
  }


  func testReturnStatements() throws {
    let tests: [(input: String, expected: Int?)] = [
//      ("return;", nil),
      ("return 10;", 10),
      ("return 10; 9;", 10),
      ("return 2 * 5; 9;", 10),
      ("9; return 2 * 5; 9;", 10),
      ("""
       if (10 > 1) { 
         if (10 > 1) {
           return 10;
         }
         return 1;
       }
       """, 10)
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)
      if let errorObj = evaluated as? ErrorObject {
        XCTFail(errorObj.message)
        return
      }

      if let expectedInt = testCase.expected {
        try validateIntegerObject(evaluated, expected: expectedInt)
      }
    }
  }


  func testErrorHandling() throws {
    let tests: [(input: String, expectedMessage: String)] = [
      ( "5 + true;", "Type mismatch: integer + boolean"),
      ( "5 + true; 5;", "Type mismatch: integer + boolean"),
      ( "-true", "Unknown operator: -boolean"),
      ( "true + false;", "Unknown operator: boolean + boolean"),
      ( "5; true + false; 5", "Unknown operator: boolean + boolean"),
      ( "if (10 > 1) { true + false; }", "Unknown operator: boolean + boolean"),
      ("""
       if (10 > 1) {
         if (10 > 1) {
           return true + false;
         }
         return 1;
       }
       """, "Unknown operator: boolean + boolean"),
      ("foobar", "Identifier not found: foobar"),

      ("\"hello, \" - \"world!\"", "Unknown operator: string - string"),
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)
      guard let errorObj = evaluated as? ErrorObject else {
        XCTFail("No error object returned. Got=\(type(of: evaluated))")
        return
      }

      XCTAssertEqual(errorObj.message, testCase.expectedMessage)
    }
  }


  func testFunctionObject() throws {
    let input = "fn(x) { x + 2; }"
    let evaluated = runEval(input)
    if let errorObj = evaluated as? ErrorObject {
      XCTFail(errorObj.message)
      return
    }

    guard let functionObject = evaluated as? FunctionObject else {
      XCTFail("No function object returned. Got=\(type(of: evaluated))")
      return
    }

    XCTAssertEqual(
      functionObject.parameters.count,
      1,
      "Function has wrong parameters. Got=\(functionObject.parameters)")

    XCTAssertEqual(
      functionObject.parameters[0].toString(),
      "x",
      "Parameter is not `x`. Got=\(functionObject.parameters[0].toString())")

    let expectedBody = "(x + 2)"
    XCTAssertEqual(functionObject.body.toString(), expectedBody)
  }


  func testFunctionApplication() throws {
    let tests: [(input: String, expected: Int)] = [
      ("let identity = fn(x) { x; }; identity(5);", 5),
      ("let identity = fn(x) { return x; }; identity(5);", 5),
      ("let double = fn(x) { x * 2; }; double(5);", 10),
      ("let add = fn(x, y) { x + y; }; add(5, 5);", 10),
      ("let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));", 20),
      ("fn(x) { x; }(5)", 5),
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)
      if let errorObj = evaluated as? ErrorObject {
        XCTFail(errorObj.message)
        return
      }

      try validateIntegerObject(evaluated, expected: testCase.expected)
    }
  }


  func testClosures() throws {
    let input = """
    let newAdder = fn(x) {
      fn(y) { x + y };
    };

    let addTwo = newAdder(2);
    addTwo(2);
    """

    let evaluated = runEval(input)
    if let errorObj = evaluated as? ErrorObject {
      XCTFail(errorObj.message)
      return
    }

    try validateIntegerObject(evaluated, expected: 4)
  }


  // MARK: - Validators


  private func validateNullObject(_ obj: Object) throws {
    guard let _ = obj as? NullObject else {
      XCTFail("object is not `Null`. Got=\(obj)")
      return
    }
  }


  private func validateBooleanObject(_ obj: Object, expected: Bool) throws {
    guard let result = obj as? BooleanObject else {
      XCTFail("object is not `Boolean`. Got=\(obj)")
      return
    }

    XCTAssertEqual(
      result.value,
      expected,
      "Object has the wrong value. Got=\(result.value), want=\(expected)")
  }


  private func validateIntegerObject(_ obj: Object, expected: Int) throws {
    guard let result = obj as? IntegerObject else {
      XCTFail("object is not `Integer`. Got=\(obj)")
      return
    }

    XCTAssertEqual(
      result.value,
      expected,
      "Object has the wrong value. Got=\(result.value), want=\(expected)")
  }


  // MARK: - Private

  private func runEval(_ input: String) -> Object {
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)
    let env = Environment()

    guard let program = parser.parseProgram(), !checkParserErrors(parser) else {
      return ErrorObject(message: "`parseProgram()` failed to parse the input.")
    }

    let evaluated = Evaluator().eval(program, within: env)
    return evaluated
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
