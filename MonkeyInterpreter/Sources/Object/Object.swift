// Created on 10/31/23.

import Foundation

/// Every value in the Monkey source code will be wrapped inside a struct, which fulfills
/// this `Object` interface.
public protocol Object {

  func type() -> ObjectType

  func inspect() -> String
}
