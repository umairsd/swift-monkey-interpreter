// Created on 10/25/23.

import Foundation
import Token

public struct Identifier{
  let token: Token
  let value: String
}


extension Identifier: Expression {

  public func expressionNode() {
  }

  public func tokenLiteral() -> String {
    return token.literal
  }
}
