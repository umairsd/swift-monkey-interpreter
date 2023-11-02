// Created on 10/25/23.

import Foundation
import Token

public class Program: Node {

  public private(set) var statements: [Statement]

  public init(statements: [Statement] = []) {
    self.statements = statements
  }

  public func appendStatement(_ s: Statement) {
    statements.append(s)
  }


  // MARK: - Protocol (Node)

  public var token: Token {
    guard let firstStatement = statements.first else {
      fatalError()
    }
    return firstStatement.token
  }


  public func toString() -> String {
    let result = statements.map { $0.toString() }.joined(separator: "\n")
    return result
  }
}
