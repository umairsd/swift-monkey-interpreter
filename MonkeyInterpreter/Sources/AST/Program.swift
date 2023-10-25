// Created on 10/25/23.

import Foundation
import Token

public class Program: Node {

  public private(set) var statements: [Statement] = []

  public init() {}

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
}
