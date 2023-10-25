// Created on 10/25/23.

import Foundation
import Token

public class LetStatement: Statement {

  /// The token that's represented by this node in the AST.
  private let token: Token
  /// The name of the variable in a let statement.
  private let name: Identifier
  /// The expression to the right of the equal sign.
  private let value: Expression


  public init(token: Token, name: Identifier, value: Expression) {
    self.token = token
    self.name = name
    self.value = value
  }

  // MARK: - Statement

  public func statementNode() {
  }

  public func tokenLiteral() -> String {
    return token.literal
  }
}
