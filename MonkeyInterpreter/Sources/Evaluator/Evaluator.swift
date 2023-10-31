// Created on 10/31/23.

import Foundation
import AST
import Object
import Token

public struct Evaluator {

  public init() {}

  public func eval(_ node: Node?) -> Object? {
    guard let node = node else {
      return nil
    }

    return switch node {
      // Statements
    case let p as Program:
      evalStatements(stmts: p.statements)

    case let exprStmt as ExpressionStatement:
      eval(exprStmt.expression)

      // Expressions
    case let intLiteral as IntegerLiteral:
      Integer(value: intLiteral.value)

    default:
      nil
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
}
