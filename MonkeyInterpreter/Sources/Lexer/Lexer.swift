// Created on 10/23/23.

import Foundation
import Token

public class Lexer {

  /// The input that represents the source code.
  private let input: String
  /// Current position in the input. It points to the current character. It is nil prior to
  /// any character being read.
  private var position: String.Index?
  /// Current character under examination.
  private var currentChar: Character?
  /// The next reading position in the input (after current character).
  private var nextReadPosition: String.Index?


  public init(input: String) {
    self.input = input
    self.nextReadPosition = input.startIndex
    moveToNextChar()
  }

  // MARK: - Public API

  public func nextToken() -> Token {
    // If the current position is at the end of the source code (`input.endIndex`),
    // return the EOF token.
    guard let p = position, p < input.endIndex else {
      return Token(type: .eof, literal: "")
    }

    skipWhitespace()

    guard let ch = currentChar else {
      return Token(type: .eof, literal: "")
    }


    var token: Token
    switch ch {
    case "=":
      if let nextCh = peekNextChar(), nextCh == "=" {
        // Since we've peeked at the next character, and want to handle it,
        // move the position forward by one.
        moveToNextChar()
        token = Token(type: .eq, literal: String(ch) + String(nextCh))
      } else {
        token = Token(type: .assign, literal: String(ch))
      }

    case "+":
      token = Token(type: .plus, literal: String(ch))
    case "-":
      token = Token(type: .minus, literal: String(ch))

    case "!":
      if let nextCh = peekNextChar(), nextCh == "=" {
        // Since we've peeked at the next character, and want to handle it,
        // move the position forward by one.
        moveToNextChar()
        token = Token(type: .notEq, literal: String(ch) + String(nextCh))
      } else {
        token = Token(type: .bang, literal: String(ch))
      }

    case "*":
      token = Token(type: .asterisk, literal: String(ch))
    case "/":
      token = Token(type: .slash, literal: String(ch))
    case "<":
      token = Token(type: .lt, literal: String(ch))
    case ">":
      token = Token(type: .gt, literal: String(ch))

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
    case "[":
      token = Token(type: .lBracket, literal: String(ch))
    case "]":
      token = Token(type: .rBracket, literal: String(ch))
    case ",":
      token = Token(type: .comma, literal: String(ch))
    case "\"":
      moveToNextChar()
      guard let str = readString() else {
        fatalError("Error: Unable to read the token for the string.")
      }
      token = Token(type: .string, literal: str)

    default:
      if ch.isLetter {
        guard let identiferName = readIdentifier() else {
          fatalError("Error: Unable to read the token for identifer name.")
        }
        let identifierType = TokenType.lookupIdentifer(identiferName)
        token = Token(type: identifierType, literal: identiferName)
        // While reading the identifer, we've already called `readChar()`. There's no need to
        // call `readChar()` at the end of the switch statement.
        return token

      } else if ch.isNumber {
        guard let number = readNumber() else {
          fatalError()
        }
        token = Token(type: .int, literal: number)
        return token

      } else {
        token = Token(type: .illegal, literal: "")
      }
    }

    moveToNextChar()
    return token
  }


  // MARK: - Private


  /// Reads in an identifier, and advances the lexer's positions until it enounters a non-letter
  /// character.
  private func readIdentifier() -> String? {
    return readCharacters { $0.isLetter }
  }


  /// Reads in an number, and advances the lexer's positions until it enounters a non-letter
  /// character.
  private func readNumber() -> String? {
    return readCharacters { $0.isNumber }
  }


  /// Reads in a string, and advances the lexer's positions until it encounters the string
  /// terminating character.
  private func readString() -> String? {
    return readCharacters { $0 != "\"" }
  }


  private func readCharacters(while predicate: (Character) -> Bool) -> String? {
    guard let startingPosition = self.position else { return nil }
    while let c = currentChar, predicate(c) {
      moveToNextChar()
    }

    guard let endingPosition = self.position else { return nil }
    let subString = input[startingPosition..<endingPosition]
    return String(subString)
  }


  /// Advances our position in the input string. If it reaches the end of the string, it
  /// sets the `currentChar` and the `nextReadPosition` to nil.
  private func moveToNextChar() {
    guard let nextPosition = nextReadPosition else {
      return
    }

    if nextPosition >= input.endIndex {
      // Off the deep end!
      currentChar = nil
      position = nextPosition
      nextReadPosition = nil
    } else {
      currentChar = input[nextPosition]
      position = nextPosition
      nextReadPosition = input.index(after: nextPosition)
    }
  }


  /// Reads the next character. This is the character at `nextReadPosition`, assuming
  /// the index is valid. 
  private func peekNextChar() -> Character? {
    guard let nextP = nextReadPosition,
            nextP < input.endIndex
    else {
      return nil
    }
    return input[nextP]
  }


  private func skipWhitespace() {
    while let ch = currentChar, ch.isWhitespace {
      moveToNextChar()
    }
  }

}
