// Created on 11/1/23.

import Foundation

public class Environment {
  public private(set) var store: [String: Object]
  /// A reference to the enclosing environment.
  /// The outer scope encloses the inner scope. The inner scope (self) *extends* the
  /// outer scope.
  public let outer: Environment?

  public init(store: [String : Object] = [:], outerEnvironment: Environment? = nil) {
    self.store = store
    self.outer = outerEnvironment
  }

  public class func newClosedEnvironment(from outer: Environment) -> Environment {
    let env = Environment(outerEnvironment: outer)
    return env
  }

  public func getObject(for name: String) -> Object? {
    if let v = store[name] {
      return v
    }
    let outerV = outer?.getObject(for: name)
    return outerV
  }

  public func setObject(for name: String, _ object: Object?) {
    guard let o = object else {
      return
    }
    store[name] = o
  }
}
