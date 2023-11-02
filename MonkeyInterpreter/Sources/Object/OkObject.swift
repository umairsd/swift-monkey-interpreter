// Created on 11/1/23.

import Foundation


/// Represents a no-op OK state.
public class OkObject: Object {
  
  public init() {}

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .ok
  }

  public func inspect() -> String {
    ""
  }
}
