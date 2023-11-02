// Created on 11/2/23.

import Foundation
import Token

/// Represents a String literal.
public class StringLiteral: Expression {
  public let value: String

  public init(token: Token, value: String) {
    self.value = value
    self.token = token
  }

  // MARK: - Protocol (Expression)

  public let token: Token

  public func toString() -> String {
    return value
  }
}
