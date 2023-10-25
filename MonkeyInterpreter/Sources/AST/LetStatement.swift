// Created on 10/25/23.

import Foundation
import Lexer

public class LetStatement {

  private let token: Token
  private let name: Identifier
  private let value: Expression


  public init(token: Token, name: Identifier, value: Expression) {
    self.token = token
    self.name = name
    self.value = value
  }
}


extension LetStatement: Statement {
  
  public func statementNode() {
  }

  public func tokenLiteral() -> String {
    return token.literal
  }
}
