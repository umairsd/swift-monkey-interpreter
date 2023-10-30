// Created on 10/30/23.

import Foundation
import Token


public class FunctionLiteral: Expression {

  public let parameters: [Identifier]
  public let body: BlockStatement

  public init(token: Token, parameters: [Identifier] = [], body: BlockStatement) {
    self.token = token
    self.parameters = parameters
    self.body = body
  }

  // MARK: - Protocol (Expression)

  public let token: Token

  public func toString() -> String {
    var output = token.literal
    output += "("
    output += parameters.map{ $0.toString() }.joined(separator: ",")
    output += ")"
    output += body.toString()
    return output
  }
}
