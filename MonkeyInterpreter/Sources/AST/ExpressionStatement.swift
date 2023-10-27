// Created on 10/27/23.

import Foundation
import Token

/// An expression statement is a statement that consists solely of one expression.
/// It is only a wrapper. Consider the example:
/// 
/// ```
/// let x = 5;
/// x + 10;
/// ```
///
/// The second line above is an "expression statement".
///
public class ExpressionStatement: Statement {

  /// The expression that's being wrapped.
  public let expression: Expression?


  public init(token: Token, expression: Expression? = nil) {
    self.expression = expression
    self.token = token
  }


  // MARK: - Protocol (Statement)

  public let token: Token


  public func toString() -> String {
    if let e = expression {
      return e.toString()
    }
    return ""
  }
}
