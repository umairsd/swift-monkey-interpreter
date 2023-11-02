// Created on 10/28/23.

import Foundation
import Token

/// Represents an integer literal.
public class IntegerLiteral: Expression {

  public let value: Int

  public init(token: Token, value: Int) {
    self.value = value
    self.token = token
  }

  // MARK: - Protocol (Expression)

  public let token: Token

  public func toString() -> String {
    return String(value)
  }
}
