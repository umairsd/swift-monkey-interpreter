// Created on 10/25/23.

import Foundation

public protocol Statement: Node {

  func statementNode()
}


extension Statement {
  
  // Default implementation. Empty
  public func statementNode() {
  }
}
