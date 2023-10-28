// Created on 10/28/23.

import Foundation
import Token

/// Represents the prefix expression, e.g. !5, or -25
public class PrefixExpression: Expression {

  public let prefixOperator: String
  public let rightExpression: Expression

  public init(token: Token, prefixOperator: String, rightExpression: Expression) {
    self.rightExpression = rightExpression
    self.prefixOperator = prefixOperator
    self.token = token
  }

  // MARK: - Protocol (Expression)

  /// The prefix token, e.g. !
  public let token: Token

  public func toString() -> String {
    "(\(prefixOperator)\(rightExpression.toString()))"
  }
}
