// Created on 10/25/23.

import Foundation
import Lexer
import Token
import Ast

public class Parser {
  
  /// Pointer to an instance of the lexer, on which we repeatedly call `nextToken` to
  /// get the next token in the input.
  private let lexer: Lexer
  /// The current token that's being parsed by the Lexer.
  private var currentToken: Token?
  /// The next token in the lexer. Used if `currentToken` doesn't give us enough
  /// information for a parsing decision.
  private var peekToken: Token?


  public init(lexer: Lexer) {
    self.lexer = lexer

    // Read two tokens so that the `currentToken` and `nextToken` are both set.
    moveToNextToken()
    moveToNextToken()
  }

  // MARK: - Public

  public func parseProgram() -> Program? {
    return nil
  }


  // MARK: - Private

  /// Helper function that advances both the token pointers.
  private func moveToNextToken() {
    currentToken = peekToken
    peekToken = lexer.nextToken()
  }
}
