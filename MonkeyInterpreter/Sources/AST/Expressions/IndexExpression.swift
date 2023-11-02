// Created on 11/2/23.

import Foundation
import Token

public class IndexExpression: Expression {

  public let left: Expression
  public let index: Expression

  public init(token: Token, left: Expression, index: Expression) {
    self.left = left
    self.index = index
    self.token = token
  }

  // MARK: - Protocol (Expression)

  public let token: Token

  public func toString() -> String {
    var output = "("
    output += left.toString()
    output += "["
    output += index.toString()
    output += "])"
    return output
  }
}
