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

  public func eval(_ node: Node?) -> Object? {
    guard let node = node else {
      return nil
    }

    switch node {
      // Statements
    case let p as Program:
      return evalProgram(p)

    case let exprStmt as ExpressionStatement:
      return eval(exprStmt.expression)

    case let blockStmt as BlockStatement:
      return evalBlockStatement(blockStmt)

    case let returnStmt as ReturnStatement:
      let v = eval(returnStmt.returnValue)
      if isError(v) {
        return v
      }
      return ReturnObject(value: v)

      // Expressions
    case let intLiteral as IntegerLiteral:
      return IntegerObject(value: intLiteral.value)

    case let booleanLiteral as BooleanLiteral:
      return booleanLiteral.value ? trueObject : falseObject

    case let prefixExpr as PrefixExpression:
      let right = eval(prefixExpr.rightExpression)
      if isError(right) {
        return right
      }
      return evalPrefixExpression(prefixExpr.prefixOperator, right)

    case let infixExpr as InfixExpression:
      let left = eval(infixExpr.leftExpression)
      if isError(left) {
        return left
      }
      let right = eval(infixExpr.rightExpression)
      if isError(right) {
        return right
      }
      return evalInfixExpression(infixExpr.infixOperator, leftObject: left, rightObject: right)

    case let ifExpr as IfExpression:
      return evalIfExpression(ifExpr)

    default:
      return newError(for: "Nil node.")
    }
  }

  // MARK: - Evaluators

  
  private func evalProgram(_ program: Program) -> Object? {
    var result: Object?

    for statement in program.statements {
      result = eval(statement)
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


  private func evalBlockStatement(_ blockStatement: BlockStatement) -> Object? {
    var result: Object?

    for statement in blockStatement.statements {
      result = eval(statement)
      // Check the `type()` of each evaluation result. If it is `.returnValue`, simply return
      // the object without unwrapping its value, so it stops execution in a possible outer
      // block statement and bubbles up to `evalProgram()` where it finally gets unwrapped.
      if let r = result, (r.type() == .return || r.type() == .error) {
        return r
      }
    }
    return result
  }


  private func evalIfExpression(_ ifExpr: IfExpression) -> Object? {
    guard let conditionObject = eval(ifExpr.condition) else {
      return newError(for: "Unable to parse the condition for if-expression.")
    }
    if isError(conditionObject) {
      return conditionObject
    }

    if isTruthy(conditionObject) {
      return eval(ifExpr.consequence)
    } else if let alternative = ifExpr.alternative {
      return eval(alternative)
    } else {
      return nullObject
    }
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
      return newError(for: "Unknown operator: \(leftInt.type()) \(infixOperator) \(leftInt.type())")
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

  
  private func isError(_ object: Object?) -> Bool {
    if let o = object {
      return o is ErrorObject
    }
    return false
  }


  private func booleanObjectFor(_ condition: Bool) -> BooleanObject {
    condition ? trueObject : falseObject
  }


  private func newError(for message: String) -> ErrorObject {
    return ErrorObject(message: message)
  }


  private func isTruthy(_ object: Object) -> Bool {
    if object === nullObject || object === falseObject {
      return false
    }
    return true
  }

}
