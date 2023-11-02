// Created on 10/28/23.

import Foundation
import Token

public class InfixExpression: Expression {
  
  public let leftExpression: Expression
  public let rightExpression: Expression
  public let infixOperator: String

  public init(
    token: Token,
    leftExpression: Expression,
    infixOperator: String,
    rightExpression: Expression
  ) {
    self.token = token
    self.leftExpression = leftExpression
    self.rightExpression = rightExpression
    self.infixOperator = infixOperator
  }


  // MARK: - Protocol (Expression)

  public let token: Token

  public func toString() -> String {
    var output = "("

    output += leftExpression.toString()
    output += " \(infixOperator) "
    output += rightExpression.toString()
    output += ")"

    return output
  }
}
