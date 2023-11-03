// Created on 10/31/23.

import Foundation

/// A type to represents an integer in the Monkey programming langauge.
public class IntegerObject: Object {
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


extension IntegerObject: DictionaryKey {

  public static func == (lhs: IntegerObject, rhs: IntegerObject) -> Bool {
    return lhs.value == rhs.value
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}
