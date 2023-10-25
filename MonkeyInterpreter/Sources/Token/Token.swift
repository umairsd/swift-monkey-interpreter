// Created on 10/23/23.

import Foundation

public struct Token {
  public let type: TokenType
  public let literal: String

  public init(type: TokenType, literal: String) {
    self.type = type
    self.literal = literal
  }
}
