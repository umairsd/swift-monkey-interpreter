// Created on 10/25/23.

import Foundation
import Token

public class LetStatement: Statement {

  /// The name of the variable in a let statement.
  public let name: Identifier
  /// The expression to the right of the equal sign.
  public let value: Expression


  public init(token: Token, name: Identifier, value: Expression) {
    self.token = token
    self.name = name
    self.value = value
  }

  // MARK: - Protocol (Statement)

  public let token: Token


  public func toString() -> String {
    var result = "\(tokenLiteral()) \(name.toString()) = "
    result += value.toString()
    result += ";"
    return result
  }
}
