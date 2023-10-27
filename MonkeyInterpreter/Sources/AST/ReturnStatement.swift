// Created on 10/25/23.

import Foundation
import Token

public class ReturnStatement: Statement {

  /// The expression to be returned.
  // TODO: Make this non-optional.
  public let returnValue: Expression?

  public init(token: Token, returnValue: Expression? = nil) {
    self.token = token
    self.returnValue = returnValue
  }


  // MARK: - Protocol (Statement)

  public let token: Token

  public func toString() -> String {
    var result = tokenLiteral()
    if let r = returnValue {
      result += " \(r.toString())"
    }
    result += ";"
    return result
  }

}

