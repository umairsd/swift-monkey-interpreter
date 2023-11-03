// Created on 11/2/23.

import Foundation
import Token

/// A type that's used as the element type for the `DictionaryLiteral` type.
public class DictionaryLiteralPair {
  public let key: Expression
  public let value: Expression

  public init(key: Expression, value: Expression) {
    self.key = key
    self.value = value
  }
}


/// A type that represents a dictionary.
public class DictionaryLiteral: Expression {

  public let pairs: [DictionaryLiteralPair]

  public init(token: Token, pairs: [DictionaryLiteralPair]) {
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
