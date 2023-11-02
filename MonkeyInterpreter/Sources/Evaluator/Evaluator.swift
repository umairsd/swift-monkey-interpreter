// Created on 10/31/23.

import Foundation
import AST
import Object
import Token

public struct Evaluator {

  private let nullObject = NullObject()
  private let trueObject = BooleanObject(value: true)
  private let falseObject = BooleanObject(value: false)

  public init() {}

  public func eval(_ node: Node?, within environment: Environment) -> Object {
    guard let node = node else {
      fatalError()
    }

    switch node {
      // Statements
    case let p as Program:
      return evalProgram(p, within: environment)

    case let exprStmt as ExpressionStatement:
      return eval(exprStmt.expression, within: environment)

    case let blockStmt as BlockStatement:
      return evalBlockStatement(blockStmt, within: environment)

    case let returnStmt as ReturnStatement:
      let v = eval(returnStmt.returnValue, within: environment)
      if isErrorObject(v) {
        return v
      }
      return ReturnObject(value: v)

    case let letStmt as LetStatement:
      let v = eval(letStmt.value, within: environment)
      if isErrorObject(v) {
        return v
      }
      environment.setObject(for: letStmt.name.value, v)
      return Ok()

      // Expressions
    case let intLiteral as IntegerLiteral:
      return IntegerObject(value: intLiteral.value)

    case let booleanLiteral as BooleanLiteral:
      return booleanLiteral.value ? trueObject : falseObject

    case let strLiteral as StringLiteral:
      return StringObject(value: strLiteral.value)

    case let identifer as Identifier:
      return evalIdentifier(identifer, within: environment)

    case let functionLiteral as FunctionLiteral:
      let params = functionLiteral.parameters
      let body = functionLiteral.body
      return FunctionObject(parameters: params, body: body, environment: environment)

    case let callExpr as CallExpression:
      let functionObj = eval(callExpr.function, within: environment)
      if isErrorObject(functionObj) {
        return functionObj
      }
      // Evaluate each of the arguments, to resolve their values. e.g. call(3 + 5) means
      // 3 + 5 needs to be resolved and evaluated to 8
      let arguments = evalExpressions(callExpr.arguments, within: environment)
      if arguments.count == 1 && isErrorObject(arguments.first!) {
        return arguments.first!
      }
      return applyFunctionObject(functionObj, to: arguments)

    case let prefixExpr as PrefixExpression:
      let right = eval(prefixExpr.rightExpression, within: environment)
      if isErrorObject(right) {
        return right
      }
      return evalPrefixExpression(prefixExpr.prefixOperator, right)

    case let infixExpr as InfixExpression:
      let left = eval(infixExpr.leftExpression, within: environment)
      if isErrorObject(left) {
        return left
      }
      let right = eval(infixExpr.rightExpression, within: environment)
      if isErrorObject(right) {
        return right
      }
      return evalInfixExpression(infixExpr.infixOperator, leftObject: left, rightObject: right)

    case let ifExpr as IfExpression:
      return evalIfExpression(ifExpr, within: environment)

    default:
      return newError(for: "Nil node.")
    }
  }

  // MARK: - Evaluators

  
  private func evalProgram(_ program: Program, within environment: Environment) -> Object {
    var result: Object = Ok()

    for statement in program.statements {
      result = eval(statement, within: environment)
      switch result {
      case let returnObject as ReturnObject:
        return returnObject.value
      case _ as ErrorObject:
        return result
      default:
        continue
      }
    }
    return result
  }


  private func evalBlockStatement(
    _ blockStatement: BlockStatement,
    within environment: Environment
  ) -> Object {

    var result: Object = Ok()

    for statement in blockStatement.statements {
      result = eval(statement, within: environment)
      // Check the `type()` of each evaluation result. If it is `.returnValue`, simply return
      // the object without unwrapping its value, so it stops execution in a possible outer
      // block statement and bubbles up to `evalProgram()` where it finally gets unwrapped.
      if (result.type() == .return || result.type() == .error) {
        return result
      }
    }
    return result
  }


  private func evalIfExpression(
    _ ifExpr: IfExpression,
    within environment: Environment
  ) -> Object {

    let conditionObject = eval(ifExpr.condition, within: environment)
    if isErrorObject(conditionObject) {
      return conditionObject
    }

    if isTruthy(conditionObject) {
      return eval(ifExpr.consequence, within: environment)
    } else if let alternative = ifExpr.alternative {
      return eval(alternative, within: environment)
    } else {
      return nullObject
    }
  }


  private func evalIdentifier(
    _ identifer: Identifier,
    within environment: Environment
  ) -> Object {

    if let v = environment.getObject(for: identifer.value) {
      return v
    }
    if let v = Builtins.builtinMap[identifer.value] {
      return v
    }
    return newError(for: "Identifier not found: \(identifer.value)")
  }


  private func evalExpressions(
    _ expressions: [Expression],
    within environment: Environment
  ) -> [Object] {

    var result: [Object] = []
    for e in expressions {
      let evaluated = eval(e, within: environment)
      if isErrorObject(evaluated) {
        return [evaluated]
      }
      result.append(evaluated)
    }
    return result
  }


  private func applyFunctionObject(_ fn: Object, to arguments: [Object]) -> Object {
    if let functionObj = fn as? FunctionObject, functionObj.type() == .function {
      let extendedEnv = extendFunctionEnvironment(functionObj, arguments: arguments)
      let evaluated = eval(functionObj.body, within: extendedEnv)
      return unwrapReturnValue(evaluated)
    }

    if let builtinObj = fn as? BuiltinObject, builtinObj.type() == .builtIn {
      return builtinObj.fn(arguments)
    }

    return newError(for: "Not a function: \(fn.type())")
  }


  // MARK: Evaluators (Infix)

  private func evalInfixExpression(
    _ infixOperator: String,
    leftObject left: Object?,
    rightObject right: Object?
  ) -> Object {

    guard let left = left, let right = right else {
      fatalError("")
    }
    guard left.type() == right.type() else {
      return newError(for: "Type mismatch: \(left.type()) \(infixOperator) \(right.type())")
    }
    guard type(of: left) == type(of: right) else {
      return newError(
        for: "Type mismatch: Objects types are different -  \(type(of: left)) \(type(of: right))")
    }

    if let i1 = left as? IntegerObject, let i2 = right as? IntegerObject {
      return evalIntegerInfixExpression(infixOperator, leftInt: i1, rightInt: i2)
    }
    if let s1 = left as? StringObject, let s2 = right as? StringObject {
      return evalStringInfixExpression(infixOperator, leftString: s1, rightString: s2)
    }

    if infixOperator == "==" {
      return booleanObjectFor(left === right)
    }

    if infixOperator == "!=" {
      return booleanObjectFor(left !== right)
    }

    return newError(for: "Unknown operator: \(left.type()) \(infixOperator) \(right.type())")
  }


  private func evalIntegerInfixExpression(
    _ infixOperator: String,
    leftInt: IntegerObject,
    rightInt: IntegerObject
  ) -> Object {

    let l = leftInt.value
    let r = rightInt.value

    switch infixOperator {
    case "+":
      return IntegerObject(value: l + r)

    case "-":
      return IntegerObject(value: l - r)

    case "*":
      return IntegerObject(value: l * r)

    case "/":
      return IntegerObject(value: l / r)

    case "<":
      return booleanObjectFor(l < r)

    case ">":
      return booleanObjectFor(l > r)

    case "==":
      return booleanObjectFor(l == r)

    case "!=":
      return booleanObjectFor(l != r)

    default:
      return newError(
        for: "Unknown operator: \(leftInt.type()) \(infixOperator) \(rightInt.type())")
    }
  }


  private func evalStringInfixExpression(
    _ infixOperator: String,
    leftString: StringObject,
    rightString: StringObject
  ) -> Object {

    let l = leftString.value
    let r = rightString.value

    switch infixOperator {
    case "+":
      return StringObject(value: l + r)

    default:
      return newError(
        for: "Unknown operator: \(leftString.type()) \(infixOperator) \(rightString.type())")
    }
  }



  // MARK: Evaluators (Prefix)

  private func evalPrefixExpression(_ prefixOperator: String, _ rightObject: Object?) -> Object {
    switch prefixOperator {
    case "!":
      return evalBangOperatorExpression(rightObject)

    case "-":
      return evalMinusPrefixOperatorExpression(rightObject)

    default:
      return ErrorObject(message: "Unknown operator: \(prefixOperator)")
    }
  }


  private func evalMinusPrefixOperatorExpression(_ right: Object?) -> Object {
    guard let rightObject = right else {
      fatalError("\(#function) Unexpected nil for the right expression in a prefix expression.")
    }
    guard let integerLiteral = rightObject as? IntegerObject, rightObject.type() == .integer else {
      return newError(for: "Unknown operator: -\(rightObject.type())")
    }

    return IntegerObject(value: -integerLiteral.value)
  }


  private func evalBangOperatorExpression(_ right: Object?) -> Object {
    guard let rightObject = right else {
      fatalError("\(#function) Unexpected nil for the right expression in a prefix expression.")
    }

    if rightObject === trueObject {
      return falseObject
    } else if rightObject === falseObject {
      return trueObject
    } else {
      return falseObject
    }
  }


  // MARK: - Helpers

  private func unwrapReturnValue(_ obj: Object) -> Object {
    if let r = obj as? ReturnObject {
      return r.value
    }
    return obj
  }


  private func extendFunctionEnvironment(_ fn: FunctionObject, arguments: [Object]) -> Environment {
    let env = Environment.newClosedEnvironment(from: fn.environment)
    for (paramIdx, param) in fn.parameters.enumerated() {
      env.setObject(for: param.value, arguments[paramIdx])
    }
    return env
  }


  private func booleanObjectFor(_ condition: Bool) -> BooleanObject {
    condition ? trueObject : falseObject
  }


  private func isTruthy(_ object: Object) -> Bool {
    if object === nullObject || object === falseObject {
      return false
    }
    return true
  }
  

  // MARK: - Errors

  private func newError(for message: String) -> ErrorObject {
    return ErrorObject(message: message)
  }

  private func isErrorObject(_ object: Object) -> Bool {
    return object is ErrorObject
  }
}
