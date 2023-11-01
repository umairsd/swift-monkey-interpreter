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
      return ReturnObject(value: v)

      // Expressions
    case let intLiteral as IntegerLiteral:
      return IntegerObject(value: intLiteral.value)

    case let booleanLiteral as BooleanLiteral:
      return booleanLiteral.value ? trueObject : falseObject

    case let prefixExpr as PrefixExpression:
      let right = eval(prefixExpr.rightExpression)
      return evalPrefixExpression(prefixExpr.prefixOperator, right)

    case let infixExpr as InfixExpression:
      let left = eval(infixExpr.leftExpression)
      let right = eval(infixExpr.rightExpression)
      return evalInfixExpression(infixExpr.infixOperator, leftObject: left, rightObject: right)

    case let ifExpr as IfExpression:
      return evalIfExpression(ifExpr)

    default:
      return nil
    }
  }

  // MARK: - Evaluators

  
  private func evalProgram(_ program: Program) -> Object? {
    var result: Object?
    for statement in program.statements {
      result = eval(statement)

      if let returnValue = result as? ReturnObject {
        return returnValue.value
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
      if let r = result, r.type() == .return {
        return r
      }
    }
    return result
  }


  private func evalMinusPrefixOperatorExpression(_ right: Object?) -> Object {
    guard let rightIntegerLiteral = right as? IntegerObject else {
      return nullObject
    }
    let v = rightIntegerLiteral.value
    return IntegerObject(value: -v)
  }


  private func evalBangOperatorExpression(_ right: Object?) -> Object {
    guard let rightObject = right else {
      return nullObject
    }

    if rightObject === trueObject {
      return falseObject
    } else if rightObject === falseObject {
      return trueObject
    } else {
      return falseObject
    }
  }

  
  private func evalIfExpression(_ ifExpr: IfExpression) -> Object? {
    guard let conditionObject = eval(ifExpr.condition) else {
      return nullObject
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

    if let i1 = left as? IntegerObject, let i2 = right as? IntegerObject {
      return evalIntegerInfixExpression(infixOperator, leftInt: i1, rightInt: i2)
    }

    if infixOperator == "==" {
      return booleanObjectFor(left === right)
    }

    if infixOperator == "!=" {
      return booleanObjectFor(left !== right)
    }

    return nullObject
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
      return nullObject
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
      return nullObject
    }
  }


  // MARK: - Helpers

  private func booleanObjectFor(_ condition: Bool) -> BooleanObject {
    condition ? trueObject : falseObject
  }


  private func isTruthy(_ object: Object) -> Bool {
    if object === nullObject || object === falseObject {
      return false
    }
    return true
  }
}
