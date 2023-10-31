// Created on 10/28/23.

import Foundation
import Token

/// Represents a boolean literal, `true` or `false`.
public class BooleanLiteral: Expression {
  public let value: Bool

  public init(token: Token, value: Bool) {
    self.value = value
    self.token = token
  }


  // MARK: - Protocol (Expression)

  public let token: Token

  public func toString() -> String {
    return token.literal
  }

}
