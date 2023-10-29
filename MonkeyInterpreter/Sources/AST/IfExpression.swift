// Created on 10/29/23.

import Foundation
import Token

public class IfExpression: Expression {

  public let condition: Expression
  public let consequence: BlockStatement
  public let alternative: BlockStatement?


  public init(
    token: Token,
    condition: Expression,
    consequence: BlockStatement,
    alternative: BlockStatement? = nil
  ) {
    self.condition = condition
    self.consequence = consequence
    self.alternative = alternative
    self.token = token
  }

  // MARK: - Protocol (Expression)

  public let token: Token

  public func toString() -> String {
    var output = "if"
    output += condition.toString()
    output += " "
    output += consequence.toString()
    if let alt = alternative {
      output += "else "
      output += alt.toString()
    }
    return output
  }
}
