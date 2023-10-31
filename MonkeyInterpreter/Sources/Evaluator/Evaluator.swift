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


  private func evalPrefixExpression(_ prefixOperator: String, _ rightObject: Object?) -> Object? {
    switch prefixOperator {
    case "!":
      return evalBangOperatorExpression(rightObject)

    case "-":
      return evalMinusPrefixOperatorExpression(rightObject)

    default:
      return nil
    }
  }


  private func evalMinusPrefixOperatorExpression(_ right: Object?) -> Object? {
    guard let rightIntegerLiteral = right as? Integer else {
      return nullObject
    }
    let v = rightIntegerLiteral.value
    return Integer(value: -v)
  }

  private func evalBangOperatorExpression(_ right: Object?) -> Object? {
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
}
