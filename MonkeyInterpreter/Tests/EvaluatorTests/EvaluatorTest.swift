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
      ("128", 128)
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
      ("false", false)
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


  // MARK: - Validators

  private func validateBooleanObject(_ obj: Object, expected: Bool) throws {
    guard let result = obj as? Boolean else {
      XCTFail("object is not `Boolean`. Got=\(obj)")
      return
    }

    XCTAssertEqual(
      result.value,
      expected,
      "Object has the wrong value. Got=\(result.value), want=\(expected)")
  }


  private func validateIntegerObject(_ obj: Object, expected: Int) throws {
    guard let result = obj as? Integer else {
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
