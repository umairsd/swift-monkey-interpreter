// Created on 11/2/23.

import Foundation

public typealias BuiltinFunction = ([Object]) -> Object


/// A type to represent built-in functions in the Monkey programming langauge.
public class BuiltinObject: Object {
  public let fn: BuiltinFunction

  public init(fn: @escaping BuiltinFunction) {
    self.fn = fn
  }

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .builtIn
  }

  public func inspect() -> String {
    "Builtin function"
  }
}
