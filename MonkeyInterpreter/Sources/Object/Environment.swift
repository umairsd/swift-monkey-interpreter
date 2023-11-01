// Created on 11/1/23.

import Foundation

public class Environment {
  public private(set) var store: [String: Object]

  public init(store: [String : Object] = [:]) {
    self.store = store
  }

  public func getObject(for name: String) -> Object? {
    return store[name]
  }

  public func setObject(for name: String, _ object: Object) {
    store[name] = object
  }
}
