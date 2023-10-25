// Created on 10/25/23.

import Foundation
import Token

/// Represents the name in a variable binding (e.g. `x` in `let x = 5`), as well
/// as an identifiers that produce values (e.g. `let x = valueProducingIdentifier`).
///
/// This second use-case is why the Identifier type is an `Expression`.
///
public class Identifier: Expression {

  public let value: String

  public init(token: Token, value: String) {
    self.token = token
    self.value = value
  }

  // MARK: - Protocol (Expression)

  public let token: Token
}
