// Created on 10/31/23.

import XCTest
import Lexer
import Object
import Parser
@testable import Evaluator

final class EvaluatorTest: XCTestCase {

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
      let evalResult = runEval(testCase.input)
      switch evalResult {
      case .failure(let errorMsg):
        XCTFail(errorMsg.rawValue)

      case .success(let obj):
        try validateIntegerObject(obj, expected: testCase.expected)
      }
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
      let evalResult = runEval(testCase.input)
      switch evalResult {
      case .failure(let errorMsg):
        XCTFail(errorMsg.rawValue)

      case .success(let obj):
        try validateBooleanObject(obj, expected: testCase.expected)
      }
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
      let evalResult = runEval(testCase.input)
      switch evalResult {
      case .failure(let errorMsg):
        XCTFail(errorMsg.rawValue)

      case .success(let obj):
        try validateBooleanObject(obj, expected: testCase.expected)
      }
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
      let evalResult = runEval(testCase.input)
      switch evalResult {
      case .failure(let errorMsg):
        XCTFail(errorMsg.rawValue)

      case .success(let obj):
        switch testCase.expected {
        case let expectedInt as Int:
          try validateIntegerObject(obj, expected: expectedInt)
        default:
          try validateNullObject(obj)
        }
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
      let evalResult = runEval(testCase.input)
      switch evalResult {
      case .failure(let errorMsg):
        XCTFail(errorMsg.rawValue)

      case .success(let obj):
        if let expectedInt = testCase.expected {
          try validateIntegerObject(obj, expected: expectedInt)
        }
      }
    }
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

  private func runEval(_ input: String) -> Result<Object, TestError> {
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)

    guard let program = parser.parseProgram(), !checkParserErrors(parser) else {
      return .failure(.parseError)
    }

    guard let evaluated = Evaluator().eval(program) else {
      return .failure(.evalError)
    }

    return .success(evaluated)
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


fileprivate enum TestError: String, Error {
  case parseError = "`parseProgram()` failed to parse the input."
  case evalError = "Unable to evaluate the parsed program."
}
