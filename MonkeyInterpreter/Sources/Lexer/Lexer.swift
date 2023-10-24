// Created on 10/23/23.

import Foundation

public class Lexer {

  /// The input that represents the source code.
  private let input: String
  /// Current position in the input. It points to the current character. It is nil prior to
  /// any character being read.
  private var position: String.Index?
  // TODO: Explore if this property can be deleted.
  /// Current character under examination.
  private var currentChar: Character?
  /// The next reading position in the input (after current character).
  private var nextReadPosition: String.Index?


  init(input: String) {
    self.input = input
    self.nextReadPosition = input.startIndex
    readChar()
  }

  // MARK: - Public API

  public func nextToken() -> Token {
    // If the current position is at the end of the source code (`input.endIndex`),
    // return the EOF token.
    guard let p = position,
            p < input.endIndex,
            let ch = currentChar
    else {
      return Token(type: .eof, literal: "")
    }

    var token: Token
    switch ch {
    case "=":
      token = Token(type: .assign, literal: String(ch))
    case ";":
      token = Token(type: .semicolon, literal: String(ch))
    case "(":
      token = Token(type: .lParen, literal: String(ch))
    case ")":
      token = Token(type: .rParen, literal: String(ch))
    case "{":
      token = Token(type: .lBrace, literal: String(ch))
    case "}":
      token = Token(type: .rBrace, literal: String(ch))
    case ",":
      token = Token(type: .comma, literal: String(ch))
    case "+":
      token = Token(type: .plus, literal: String(ch))

    default:
      token = Token(type: .illegal, literal: "")
    }

    readChar()
    return token
  }

  
  // MARK: - Private

  func readChar() {
    guard let nextPosition = nextReadPosition else {
      return
    }

    if nextPosition >= input.endIndex {
      // Off the deep end!
      currentChar = nil
      nextReadPosition = nil
    } else {
      currentChar = input[nextPosition]
      position = nextReadPosition
      nextReadPosition = input.index(after: nextPosition)
    }
  }

}
