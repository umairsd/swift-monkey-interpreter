// Created on 10/25/23.

import Foundation

public class Program: Node {

  private var statements: [Statement]

  public init(statements: [Statement]) {
    self.statements = statements
  }

  public func tokenLiteral() -> String {
    guard let firstStatement = statements.first else {
      return ""
    }
    return firstStatement.tokenLiteral()
  }
}
