// Created on 10/31/23.

import Foundation

/// A type to represent booleans in the Monkey programming langauge.
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


extension BooleanObject: DictionaryKey {

  public static func == (lhs: BooleanObject, rhs: BooleanObject) -> Bool {
    return lhs.value == rhs.value
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}
