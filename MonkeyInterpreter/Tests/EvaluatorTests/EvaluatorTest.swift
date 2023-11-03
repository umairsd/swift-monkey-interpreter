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


  // MARK: - Dictionary


  func testEvalDictionaryLiteral() throws {
    let input = """
    let two = "two";
    {
      "one": 10 - 9,
      two: 1 + 1,
      "thr" + "ee": 6 / 2,
      4: 4,
      true: 5,
      false: 6
    }
    """

    let expected: [AnyHashable: Int] = [
      StringObject(value: "one"): 1,
      StringObject(value: "two"): 2,
      StringObject(value: "three"): 3,
      IntegerObject(value: 4): 4,
      BooleanObject(value: true): 5,
      BooleanObject(value: false): 6,
    ]

    let evaluated = runEval(input)
    if let errorObj = evaluated as? ErrorObject {
      XCTFail(errorObj.message)
      return
    }

    guard let dict = evaluated as? DictionaryObject else {
      XCTFail("The evaluated result is not a `DictionaryObject`")
      return
    }

    XCTAssertEqual(dict.innerMap.count, expected.count)

    for (expectedKey, expectedValue) in expected {
      guard let pair = dict.innerMap[expectedKey] else {
        XCTFail("No value in the innerMap for the given key \(expectedKey).")
        return
      }

      try validateIntegerObject(pair.value, expected: expectedValue)
    }
  }


  // MARK: - Array


  func testArrayIndexExpressions() throws {
    let tests: [(input: String, expected: Any?)] = [
      ("[1, 2, 3][0]", 1),
      ("[1, 2, 3][1]", 2),
      ("[1, 2, 3][2]", 3),
      ("let i = 0; [1][i];", 1),
      ("[1, 2, 3][1 + 1];", 3),
      ("let myArray = [1, 2, 3]; myArray[2];", 3),
      ("let myArray = [1, 2, 3]; myArray[0] + myArray[1] + myArray[2];", 6),
      ("let myArray = [1, 2, 3]; let i = myArray[0]; myArray[i]", 2),
      ("[1, 2, 3][3]", nil),
      ("[1, 2, 3][-1]",  nil),
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)

      switch testCase.expected {
      case let expectedStr as String:
        if let errorObj = evaluated as? ErrorObject {
          XCTAssertEqual(errorObj.message, expectedStr)
        } else {
          XCTFail("Object is not ErrorObject. Got=\(evaluated)")
        }

      case let exptectedInt as Int:
        if let errorObj = evaluated as? ErrorObject {
          XCTFail(errorObj.message)
        } else {
          try validateIntegerObject(evaluated, expected: exptectedInt)
        }

      default:
        guard let _ = evaluated as? NullObject, testCase.expected == nil else  {
          XCTFail("Got as NullObject when the expectation was not nil.")
          return
        }
      }
    }
  }


  func testArrayOperations() throws {
    let tests: [(input: String, expected: Any?)] = [
      ("""
      let map = fn(arr, f) {
        let iter = fn(arr, accumulated) {
          if (len(arr) == 0) {
            accumulated
          } else {
            iter(rest(arr), push(accumulated, f(first(arr))));
          }
        };

        iter(arr, []);
      };

      let a = [1, 2, 3, 4];
      let double = fn(x) { x * 2 };
      map(a, double);
      """, [2,4,6,8]),

      ("""
      let reduce = fn(arr, initial, f) {
        let iter = fn(arr, result) {
          if (len(arr) == 0) {
            result
          } else {
            iter(rest(arr), f(result, first(arr)));
          }
        };
        iter(arr, initial);
      };

      let sum = fn(arr) {
        reduce(arr, 0, fn(initial, el) { initial + el });
      };

      sum([1,2,3,4,5]);
      """, 15)
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)

      switch testCase.expected {
      case let expectedStr as String:
        if let errorObj = evaluated as? ErrorObject {
          XCTAssertEqual(errorObj.message, expectedStr)
        } else {
          XCTFail("Object is not ErrorObject. Got=\(evaluated)")
        }

      case let exptectedInt as Int:
        if let errorObj = evaluated as? ErrorObject {
          XCTFail(errorObj.message)
        } else {
          try validateIntegerObject(evaluated, expected: exptectedInt)
        }

      case let expectedArray as Array<Int>:
        if let errorObj = evaluated as? ErrorObject {
          XCTFail(errorObj.message)
        } else if let arrayObj = evaluated as? ArrayObject {
          XCTAssertEqual(arrayObj.elements.count, expectedArray.count)

          for (i, expectedElem) in expectedArray.enumerated() {
            try validateIntegerObject(arrayObj.elements[i], expected: expectedElem)
          }

        } else {
          XCTFail("Object not ArrayObject. Got=\(evaluated)")
          return
        }

      default:
        if testCase.expected == nil {
          if evaluated is OkObject || evaluated is NullObject {
            // All good. Continue
          } else {
            XCTFail("Expected `nil`. Got=\(evaluated)")
            return
          }
        } else {
          XCTFail("Unsupported type in the test case.")
          return
        }
      }
    }
  }


  // MARK: - Functions


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


  func testBuiltinFunction() throws {
    let tests: [(input: String, expected: Any?)] = [
      ("len(\"\")", 0),
      ("len(\"four\")", 4),
      ("len(\"hello world\")", 11),
      ("len(1)", "Argument to `len` not supported. Got integer"),
      ("len(\"one\", \"two\")", "Wrong number of arguments. Got=2, want=1"),
      ("len([1, 2, 3])", 3),
      ("len([])", 0),
      ("puts(\"hello\", \"world!\")", nil),
      ("first([1, 2, 3])", 1),
      ("first([])", nil),
      ("first(1)", "Argument to `first` must be array. Got integer."),
      ("last([1, 2, 3])", 3),
      ("last([])", nil),
      ("last(1)", "Argument to `last` must be array. Got integer."),
      ("rest([1, 2, 3])", [2, 3]),
      ("rest([])", nil),
      ("push([], 1)", [1]),
      ("push(1, 1)", "Argument to `push` must be array. Got integer."),
    ]

    for testCase in tests {
      let evaluated = runEval(testCase.input)

      switch testCase.expected {
      case let expectedStr as String:
        if let errorObj = evaluated as? ErrorObject {
          XCTAssertEqual(errorObj.message, expectedStr)
        } else {
          XCTFail("Object is not ErrorObject. Got=\(evaluated)")
        }

      case let exptectedInt as Int:
        if let errorObj = evaluated as? ErrorObject {
          XCTFail(errorObj.message)
        } else {
          try validateIntegerObject(evaluated, expected: exptectedInt)
        }

      case let expectedArray as Array<Int>:
        if let errorObj = evaluated as? ErrorObject {
          XCTFail(errorObj.message)
        } else if let arrayObj = evaluated as? ArrayObject {
          XCTAssertEqual(arrayObj.elements.count, expectedArray.count)

          for (i, expectedElem) in expectedArray.enumerated() {
            try validateIntegerObject(arrayObj.elements[i], expected: expectedElem)
          }

        } else {
          XCTFail("Object not ArrayObject. Got=\(evaluated)")
          return
        }

      default:
        if testCase.expected == nil {
          if evaluated is OkObject || evaluated is NullObject {
            // All good. Continue
          } else {
            XCTFail("Expected `nil`. Got=\(evaluated)")
            return
          }
        } else {
          XCTFail("Unsupported type in the test case.")
          return
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
