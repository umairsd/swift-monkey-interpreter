// Created on 10/31/23.

import Foundation

/// A type that wraps integer values.
public class Integer: Object {
  /// The value being wrapped by the `Integer` type.
  public let value: Int

  public init(value: Int) {
    self.value = value
  }

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .integer
  }

  public func inspect() -> String {
    return String(value)
  }
}
