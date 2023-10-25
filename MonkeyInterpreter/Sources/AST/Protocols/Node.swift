// Created on 10/25/23.

import Foundation

public protocol Node {

  /// Return the token literal for the current node.
  /// This is mostly used for debugging.
  func tokenLiteral() -> String
}
