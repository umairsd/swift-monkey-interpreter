// Created on 11/1/23.

import Foundation
import AST


/// A type to represents a function in the Monkey programming langauge.
public class FunctionObject: Object {

  public let parameters: [Identifier]
  public let body: BlockStatement
  public let environment: Environment

  public init(parameters: [Identifier], body: BlockStatement, environment: Environment) {
    self.parameters = parameters
    self.body = body
    self.environment = environment
  }

  // MARK: - Protocol (Object)

  public func type() -> ObjectType {
    .function
  }

  public func inspect() -> String {
    var output = ""
    output += "("
    output += parameters.map{ $0.toString() }.joined(separator: ",")
    output += ")"
    output += "{\n"
    output += body.toString()
    output += "\n}"
    return output
  }
}
