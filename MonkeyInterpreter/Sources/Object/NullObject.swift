// Created on 10/31/23.

import Foundation

/// A type to represent `null` values.
public class NullObject: Object {

  public init() {}

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .null
  }

  public func inspect() -> String {
    "null"
  }
}
