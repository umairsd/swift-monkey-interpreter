// Created on 10/25/23.

import Foundation

public class Program: Node {

  public private(set) var statements: [Statement] = []

  public init() {}

  public func tokenLiteral() -> String {
    guard let firstStatement = statements.first else {
      return ""
    }
    return firstStatement.tokenLiteral()
  }

  public func appendStatement(_ s: Statement) {
    statements.append(s)
  }
}
