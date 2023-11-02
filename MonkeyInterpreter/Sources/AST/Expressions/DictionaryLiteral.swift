// Created on 11/2/23.

import Foundation
import Token


public class DictionaryEntity {
  public let key: Expression
  public let value: Expression

  public init(key: Expression, value: Expression) {
    self.key = key
    self.value = value
  }
}


/// A type that represents a dictionary.
public class DictionaryLiteral: Expression {

  public let pairs: [DictionaryEntity]

  public init(token: Token, pairs: [DictionaryEntity]) {
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
