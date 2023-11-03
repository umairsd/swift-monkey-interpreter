// Created on 10/31/23.

import Foundation

/// Every value in the Monkey source code will be wrapped inside a type, which fulfills
/// this `Object` interface.
public protocol Object: AnyObject {

  func type() -> ObjectType

  func inspect() -> String
}
