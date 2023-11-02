// Created on 11/2/23.

import Foundation

/// A type that wraps String values.
public class StringObject: Object {

  public let value: String

  public init(value: String) {
    self.value = value
  }

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .string
  }

  public func inspect() -> String {
    return value
  }
}
