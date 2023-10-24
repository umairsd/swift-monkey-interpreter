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
