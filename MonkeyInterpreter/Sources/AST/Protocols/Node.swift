// Created on 10/25/23.

import Foundation
import Token


/// Represents a node within the Abstract Syntax Tree (AST).
public protocol Node {

  /// The token that's represented by this node in the AST.
  var token: Token { get }

  /// Return the token literal for the current node.
  /// This is mostly used for debugging.
  func tokenLiteral() -> String

  /// Allows the ability to print the AST nodes for debugging.
  func toString() -> String
}


extension Node {

  public func tokenLiteral() -> String {
    return token.literal
  }


  public func toString() -> String {
    return token.literal
  }
}
