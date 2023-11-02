// Created on 11/2/23.

import Foundation
import Token

/// A type that represents an Array.
public class ArrayLiteral: Expression {
  // The list of elements in the array.
  public let elements: [Expression]

  public init(token: Token, elements: [Expression]) {
    self.elements = elements
    self.token = token
  }

  // MARK: - Protocol (Expression)

  public let token: Token

  public func toString() -> String {
    var output = ""
    output += "["
    output += elements.map{ $0.toString() }.joined(separator: ",")
    output += "]"
    return output
  }
}
