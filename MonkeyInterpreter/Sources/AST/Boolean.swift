// Created on 10/28/23.

import Foundation
import Token


public class Boolean: Expression {
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
