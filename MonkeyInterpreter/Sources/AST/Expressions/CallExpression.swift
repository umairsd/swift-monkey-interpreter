// Created on 10/30/23.

import Foundation
import Token

public class CallExpression: Expression {

  public let function: Expression
  public let arguments: [Expression]

  public init(token: Token, function: Expression, arguments: [Expression] = []) {
    self.function = function
    self.arguments = arguments
    self.token = token
  }


  // MARK: - Protocol (Expression)

  public let token: Token

  public func toString() -> String {
    var output = function.tokenLiteral()
    output += "("
    output += arguments.map{ $0.toString() }.joined(separator: ", ")
    output += ")"
    return output
  }
}
