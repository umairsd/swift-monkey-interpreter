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
  case assign
  case plus
  case minus
  case bang = "!"
  case asterisk = "*"
  case slash = "/"
  case lt
  case gt 
  case eq
  case notEq

  // Delimiters
  case comma
  case semicolon

  case lParen
  case rParen
  case lBrace
  case rBrace

  // Keywords
  case function
  case `let`
  case `true`
  case `false`
  case `if`
  case `else`
  case `return`
}


extension TokenType {

  /// A map of keywords in the Money language.
  private static let keywords: [String: TokenType] = [
    "fn": .function,
    "let": .let,
    "true": .true,
    "false": .false,
    "if": .if,
    "else": .else,
    "return": .return
  ]


  /// Given the name of an identifer, returns the corresponding `keyword`, if any exists.
  /// Otherwise, returns `.ident` to signify a generic identifier.
  public static func lookupIdentifer(_ identifer: String) -> TokenType {
    if let type = Self.keywords[identifer] {
      return type
    }

    return .ident
  }
}
