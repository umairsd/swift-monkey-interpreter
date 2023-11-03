// Created on 11/1/23.

import Foundation

/// A type to represents an error in the Monkey programming langauge.
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
