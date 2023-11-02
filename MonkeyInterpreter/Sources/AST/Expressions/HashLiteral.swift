// Created on 11/2/23.

import Foundation
import Token


public class HashEntity {
  public let key: Expression
  public let value: Expression

  public init(key: Expression, value: Expression) {
    self.key = key
    self.value = value
  }
}


/// A type that represents a HashMap.
public class HashLiteral: Expression {

  public let pairs: [HashEntity]

  public init(token: Token, pairs: [HashEntity]) {
    self.pairs = pairs
    self.token = token
  }

  // MARK: - Protocol (Expression)

  public let token: Token // The "{" token.

  public func toString() -> String {
    var output = ""
    output += "{"
    output += pairs
      .map{ "\($0.key.tokenLiteral()): \($0.value.tokenLiteral())" }
      .joined(separator: ", ")
    output += "}"
    return output
  }
}
