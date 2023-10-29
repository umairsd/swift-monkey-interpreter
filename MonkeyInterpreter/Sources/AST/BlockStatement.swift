// Created on 10/29/23.

import Foundation
import Token

/// Represents a block of code.
public class BlockStatement: Statement {
  
  public private(set) var statements: [Statement]

  public init(token: Token, statements: [Statement] = []) {
    self.token = token
    self.statements = statements
  }

  public func appendStatement(_ s: Statement) {
    statements.append(s)
  }

  // MARK: - Protocol (Statement)

  public let token: Token // The { token

  public func toString() -> String {
    var result = "{"
    result += "\n"
    result += statements.map { $0.toString() }.joined(separator: "\n")
    result += "\n"
    result += "}"
    return result
  }
}
