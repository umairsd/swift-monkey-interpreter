// Created on 10/31/23.

import Foundation

/// A type that wraps boolean values.
public class BooleanObject: Object {
  public let value: Bool

  public init(value: Bool) {
    self.value = value
  }

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .boolean
  }

  public func inspect() -> String {
    return String(value)
  }
}