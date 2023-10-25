// Created on 10/25/23.

import Foundation
import Token

/// Represents the name in a variable binding (e.g. `x` in `let x = 5`), as well
/// as an identifiers that produce values (e.g. `let x = valueProducingIdentifier`).
///
/// This second use-case is why the Identifier type is an `Expression`.
///
public struct Identifier: Expression {
  let token: Token
  let value: String

  // MARK: - Expression

  public func expressionNode() {
  }

  public func tokenLiteral() -> String {
    return token.literal
  }
}
