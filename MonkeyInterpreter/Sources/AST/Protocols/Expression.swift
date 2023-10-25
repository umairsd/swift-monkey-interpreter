// Created on 10/25/23.

import Foundation

public protocol Expression: Node {
  
  func expressionNode()
}


extension Expression {

  // Default implementation. Empty
  public func expressionNode() {
  }
}
