// Created on 11/2/23.

import Foundation

/// A type to represent arrays in the Monkey programming langauge.
public class ArrayObject: Object {
  public let elements: [Object]

  public init(elements: [Object]) {
    self.elements = elements
  }

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .array
  }

  public func inspect() -> String {
    var output = ""
    output += "["
    output += elements.map{ $0.inspect() }.joined(separator: ", ")
    output += "]"
    return output
  }
}

