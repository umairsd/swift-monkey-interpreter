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

  public private(set) var errors: [String] = []


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
    return switch currentToken.type {
    case .let:
      parseLetStatement()
    case .return:
      parseReturnStatement()
    default:
      nil
    }
  }


  /// Parses a `LetStatement` starting from the current token.
  private func parseLetStatement() -> Statement? {
    assert(currentToken.type == .let)

    let t = currentToken

    // Parse the name.
    guard expectPeekAndContinue(.ident) else { return nil }
    let nameIdentifier = Identifier(token: currentToken, value: currentToken.literal)

    // Parse the assignment operator.
    guard expectPeekAndContinue(.assign) else { return nil }

    // Parse the assignment expression.
    // TODO: We're skipping the "expression" part for now.
    while !currentTokenIs(.semicolon) {
      moveToNextToken()
    }

    let stmt = LetStatement(token: t, name: nameIdentifier)
    return stmt
  }


  /// Parses a return statement starting from the current token.
  private func parseReturnStatement() -> Statement? {
    assert(currentToken.type == .return)

    let t = currentToken

    // Parse the expression to be returned
    // TODO: We're skipping the "expression" part for now.
    while !currentTokenIs(.semicolon) {
      moveToNextToken()
    }

    let stmt = ReturnStatement(token: t)
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


  /// Validates that the `peekToken` is of the expected type. If so, it increments the two
  /// tokens and returns true. If the `peekToken`
  private func expectPeekAndContinue(_ tokenType: TokenType) -> Bool {
    if peekTokenIs(tokenType) {
      moveToNextToken()
      return true
    } else {
      peekError(tokenType)
      return false
    }
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


  private func peekError(_ tokenType: TokenType) {
    let peekTokenString = peekToken == nil ? "nil" : "\(peekToken!.type)"
    let message = "expected next token to be \(tokenType), got \(peekTokenString) instead."
    errors.append(message)
  }
}
