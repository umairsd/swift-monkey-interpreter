// Created on 10/23/23.

import Foundation

/// Token types for the Monkey programming language.
public enum TokenType: String {
  case illegal
  case eof

  // Identifiers + literals
  case ident
  case int

  // Operators
  case assign = "="
  case plus = "+"

  // Delimiters
  case comma = ","
  case semicolon = ";"

  case lParen = "("
  case rParen = ")"
  case lBrace = "{"
  case rBrace = "}"

  // Keywords
  case function = "Function"
  case `let` = "let"
}


extension TokenType {

  /// A map of keywords in the Money language.
  private static let keywords: [String: TokenType] = [
    "fn": .function,
    "let": .let
  ]


  /// Given the name of an identifer, returns the corresponding `keyword`, if any exists.
  /// Otherwise, returns `.ident` to signify a generic identifier.
  static func lookupIdentifer(_ identifer: String) -> TokenType {
    if let type = Self.keywords[identifer] {
      return type
    }

    return .ident
  }
}
