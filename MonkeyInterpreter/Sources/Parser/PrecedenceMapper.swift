// Created on 10/28/23.

import Foundation
import Token

public struct PrecedenceMapper {

  /// Maps the token type to its precedence.
  private static let tokenToPrecedenceMap: [TokenType: Precedence] = [
    .eq: .equals,
    .notEq: .equals,
    .lt: .lessGreater,
    .gt: .lessGreater,
    .plus: .sum,
    .minus: .sum,
    .slash: .product,
    .asterisk: .product,
    .lParen: .call,
    .lBracket: .index
  ]

  /// Gets the precedence for a  given token type.
  public func precedence(for token: Token?) -> Precedence {
    guard let t = token else {
      return .lowest
    }
    return Self.tokenToPrecedenceMap[t.type, default: .lowest]
  }
}
