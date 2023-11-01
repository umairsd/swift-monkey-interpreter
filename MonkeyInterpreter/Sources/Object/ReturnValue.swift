// Created on 11/1/23.

import Foundation

public class ReturnValue: Object {
  /// The value being wrapped by the `ReturnValue` type.
  public let value: Object?

  public init(value: Object?) {
    self.value = value
  }

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .returnValue
  }

  public func inspect() -> String {
    if let v = value {
      return v.inspect()
    }
    return ""
  }
}
