// Created on 10/25/23.

import Foundation
import Lexer
import Token
import AST

public class Parser {
  
  /// Pointer to an instance of the lexer, on which we repeatedly call `nextToken` to
  /// get the next token in the input.
  private let lexer: Lexer
  /// The current token that's being parsed by the Lexer.
  private var currentToken: Token
  /// The next token in the lexer. Used if `currentToken` doesn't give us enough
  /// information for a parsing decision.
  private var peekToken: Token?


  public init(lexer: Lexer) {
    self.lexer = lexer

    // Read two tokens so that the `currentToken` and `nextToken` are both set.
    currentToken = lexer.nextToken()
    peekToken = lexer.nextToken()
  }

  // MARK: - Public

  public func parseProgram() -> Program? {
    let program = Program()

    while currentToken.type != .eof, let statement = parseStatement() {
      program.appendStatement(statement)
      moveToNextToken()
    }
    return program
  }

  // MARK: - Private (Parse)

  /// Parses a `Statement` based on the type of the current token.
  private func parseStatement() -> Statement? {
    switch currentToken.type {
    case .let:
      return parseLetStatement()
    default:
      return nil
    }
  }


  /// Parses a `LetStatement` starting from the current token.
  private func parseLetStatement() -> Statement? {
    let t = currentToken

    // Parse the name.
    guard peekTokenIs(.ident) else {
      return nil
    }
    moveToNextToken()
    let nameIdentifier = Identifier(token: currentToken, value: currentToken.literal)

    // Parse the assignment operator.
    guard peekTokenIs(.assign) else {
      return nil
    }
    moveToNextToken()

    // Parse the assignment expression.
    // TODO: We're skipping the "expression" part for now.
    moveToNextToken()

    guard peekTokenIs(.semicolon) else {
      return nil
    }
    moveToNextToken()

    let stmt = LetStatement(token: t, name: nameIdentifier)
    return stmt
  }


  // MARK: - Private (Helpers)

  /// Helper function that advances both the token pointers.
  private func moveToNextToken() {
    guard let pT = peekToken else {
      fatalError()
    }
    currentToken = pT
    peekToken = lexer.nextToken()
  }


  private func currentTokenIs(_ tokenType: TokenType) -> Bool {
    return currentToken.type == tokenType
  }

  private func peekTokenIs(_ tokenType: TokenType) -> Bool {
    guard let peek = peekToken else {
      return false
    }
    return peek.type == tokenType
  }
}
