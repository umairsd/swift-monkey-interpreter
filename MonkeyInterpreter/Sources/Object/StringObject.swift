// Created on 11/2/23.

import Foundation

/// A type to represent a string in the Monkey programming langauge.
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


extension StringObject: DictionaryKey {

  public static func == (lhs: StringObject, rhs: StringObject) -> Bool {
    return lhs.value == rhs.value
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}
