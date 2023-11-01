// Created on 11/1/23.

import Foundation

/// An type that wraps an error message.
public class ErrorObject: Object {
  /// The error message.
  public let message: String

  public init(message: String) {
    self.message = message
  }

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .error
  }

  public func inspect() -> String {
    "ERROR: \(message)"
  }
}
