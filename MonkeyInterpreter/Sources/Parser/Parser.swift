// Created on 10/25/23.

import Foundation
import Lexer
import Token
import AST

// TODO: Explore changing such that these functions accept the `Token` type.
public typealias PrefixParseFn = () -> Expression?
public typealias InfixParseFn = (Expression) -> Expression?

public class Parser {

  /// Pointer to an instance of the lexer, on which we repeatedly call `nextToken` to
  /// get the next token in the input.
  private let lexer: Lexer
  /// The current token that's being parsed by the Lexer.
  private var currentToken: Token
  /// The next token in the lexer. Used if `currentToken` doesn't give us enough
  /// information for a parsing decision.
  private var peekToken: Token?
  /// A list of errors generated during parsing.
  public private(set) var errors: [String] = []

  /// Map of token type to the function that that parses that function (Prefix).
  private var prefixParseFunctions: [TokenType: PrefixParseFn] = [:]
  /// Map of token type to the function that that parses that function (Infix).
  private var infixParseFunctions: [TokenType: InfixParseFn] = [:]


  public init(lexer: Lexer) {
    self.lexer = lexer

    // Read two tokens so that the `currentToken` and `nextToken` are both set.
    currentToken = lexer.nextToken()
    peekToken = lexer.nextToken()

    // Register parsing functions for each token type. These functions will be called
    // when we encounter a token of the given type.
    registerPrefix(for: .ident, fn: parseIdentifer)
    registerPrefix(for: .int, fn: parseIntegerLiteral)
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


  public func registerPrefix(for tokenType: TokenType, fn: @escaping PrefixParseFn) {
    prefixParseFunctions[tokenType] = fn
  }

  public func registerInfix(for tokenType: TokenType, fn: @escaping InfixParseFn) {
    infixParseFunctions[tokenType] = fn
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
      parseExpressionStatement()
    }
  }


  /// Parses an `ExpressionStatement` starting from the current token.
  private func parseExpressionStatement() -> ExpressionStatement? {
    let stmt = ExpressionStatement(
      token: currentToken,
      expression: parseExpressionWith(precedence: .lowest))

    if peekTokenIs(.semicolon) {
      moveToNextToken()
    }
    return stmt
  }


  private func parseExpressionWith(precedence: Precedence) -> Expression? {
    guard let prefixFn = prefixParseFunctions[currentToken.type] else {
      return nil
    }
    let leftExp = prefixFn()
    return leftExp
  }


  /// Parses a `LetStatement` starting from the current token.
  private func parseLetStatement() -> LetStatement? {
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
  private func parseReturnStatement() -> ReturnStatement? {
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


  private func parseIdentifer() -> Expression {
    assert(currentTokenIs(.ident))
    return Identifier(token: self.currentToken, value: self.currentToken.literal)
  }


  private func parseIntegerLiteral() -> Expression {
    assert(currentTokenIs(.int))
    guard let intValue = Int(currentToken.literal) else {
      fatalError("Unable to parse integer from the value. Got=\(currentToken.literal)")
    }
    return IntegerLiteral(token: self.currentToken, value: intValue)
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
