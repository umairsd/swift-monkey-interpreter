// Created on 10/31/23.

import Foundation

/// A type that wraps integer values.
public struct Null: Object {

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .null
  }

  public func inspect() -> String {
    "null"
  }
}