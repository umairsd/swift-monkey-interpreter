// Created on 10/31/23.

import Foundation
import AST
import Object
import Token

public struct Evaluator {

  private let nullObject = Null()
  private let trueObject = Boolean(value: true)
  private let falseObject = Boolean(value: false)

  public init() {}

  public func eval(_ node: Node?) -> Object? {
    guard let node = node else {
      return nil
    }

    switch node {
      // Statements
    case let p as Program:
      return evalStatements(stmts: p.statements)

    case let exprStmt as ExpressionStatement:
      return eval(exprStmt.expression)

      // Expressions
    case let intLiteral as IntegerLiteral:
      return Integer(value: intLiteral.value)

    case let booleanLiteral as BooleanLiteral:
      return booleanLiteral.value ? trueObject : falseObject

    case let prefixExpr as PrefixExpression:
      let right = eval(prefixExpr.rightExpression)
      return evalPrefixExpression(prefixExpr.prefixOperator, right)

    case let infixExpr as InfixExpression:
      let left = eval(infixExpr.leftExpression)
      let right = eval(infixExpr.rightExpression)
      return evalInfixExpression(infixExpr.infixOperator, leftObject: left, rightObject: right)

    default:
      return nil
    }
  }

  // MARK: - Private

  
  private func evalStatements(stmts: [Statement]) -> Object? {
    var result: Object?
    for stmt in stmts {
      result = eval(stmt)
    }
    return result
  }


  // MARK: Private (Infix)


  private func evalInfixExpression(
    _ infixOperator: String,
    leftObject left: Object?,
    rightObject right: Object?
  ) -> Object {

    if let i1 = left as? Integer, let i2 = right as? Integer {
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
    leftInt: Integer,
    rightInt: Integer
  ) -> Object {

    let l = leftInt.value
    let r = rightInt.value

    switch infixOperator {
    case "+":
      return Integer(value: l + r)

    case "-":
      return Integer(value: l - r)

    case "*":
      return Integer(value: l * r)

    case "/":
      return Integer(value: l / r)

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


  // MARK: Private (Prefix)

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


  private func evalMinusPrefixOperatorExpression(_ right: Object?) -> Object {
    guard let rightIntegerLiteral = right as? Integer else {
      return nullObject
    }
    let v = rightIntegerLiteral.value
    return Integer(value: -v)
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


  private func booleanObjectFor(_ condition: Bool) -> Boolean {
    condition ? trueObject : falseObject
  }
}
