// Created on 11/3/23.

import Foundation


public class DictionaryObjectPair {
  public let key: Object
  public let value: Object

  public init(key: Object, value: Object) {
    self.key = key
    self.value = value
  }
}


/// A type to represent a dictionary in the Monkey programming langauge.
public class DictionaryObject: Object {
  public let innerMap: [AnyHashable: DictionaryObjectPair]

  public init(valuesMap: [AnyHashable : DictionaryObjectPair]) {
    self.innerMap = valuesMap
  }

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .dictionary
  }

  public func inspect() -> String {
    var output = ""
    output += "{"
    output += innerMap.values
      .map { "\($0.key.inspect()): \($0.value.inspect())" }
      .joined(separator: ", ")
    output += "}"
    return output
  }
}
