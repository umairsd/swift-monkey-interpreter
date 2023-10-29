// Created on 10/25/23.

import Foundation
import Lexer
import Token
import AST

// TODO: Explore changing such that these functions accept the `Token` type.
public typealias PrefixParseFn = () -> Expression?
public typealias InfixParseFn = (Expression?) -> Expression?


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


  /// Precedence mapper.
  private let precedenceMapper = PrecedenceMapper()
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
    registerPrefix(for: .bang, fn: parsePrefixExpression)
    registerPrefix(for: .minus, fn: parsePrefixExpression)
    registerPrefix(for: .true, fn: parseBoolean)
    registerPrefix(for: .false, fn: parseBoolean)
    registerPrefix(for: .lParen, fn: parseGroupedExpression)
    registerPrefix(for: .if, fn: parseIfExpression)

    registerInfix(for: .plus, fn: parseInfixExpression(left:))
    registerInfix(for: .minus, fn: parseInfixExpression(left:))
    registerInfix(for: .asterisk, fn: parseInfixExpression(left:))
    registerInfix(for: .slash, fn: parseInfixExpression(left:))
    registerInfix(for: .lt, fn: parseInfixExpression(left:))
    registerInfix(for: .gt, fn: parseInfixExpression(left:))
    registerInfix(for: .eq, fn: parseInfixExpression(left:))
    registerInfix(for: .notEq, fn: parseInfixExpression(left:))
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
      expression: parseExpression(withPrecedence: .lowest))

    if peekTokenIs(.semicolon) {
      moveToNextToken()
    }
    return stmt
  }


  /// Parses an expression with a given precedence (defaults to `.lowest`).
  private func parseExpression(withPrecedence p: Precedence) -> Expression? {
    guard let prefixFn = prefixParseFn(for: currentToken) else {
      noPrefixParseFnError(currentToken.type)
      return nil
    }
    var leftExp = prefixFn()

    // The magic: In the loop’s body the method tries to find infixParseFns for the next
    // token. If it finds such a function, it calls it, passing in the expression returned
    // by a prefixParseFn as an argument. And it does all this again and again until it
    // encounters a token that has a lower precedence.
    while !peekTokenIs(.semicolon) && p.rawValue < peekPrecedence().rawValue {
      guard let infixFn = infixParseFn(for: peekToken) else {
        return leftExp
      }

      moveToNextToken()
      leftExp = infixFn(leftExp)
    }
    return leftExp
  }


  /// Parse grouped expressions, i.e. expressions grouped by parenthesis.
  private func parseGroupedExpression() -> Expression? {
    guard currentTokenIs(.lParen) else {
      return nil
    }

    moveToNextToken()
    let expr = parseExpression(withPrecedence: .lowest)

    guard expectPeekAndContinue(.rParen) else {
      return nil
    }
    return expr
  }


  private func parseIfExpression() -> Expression? {
    guard currentTokenIs(.if) else { return nil }

    let token = currentToken // the `if`.

    // After this call, currentToken is "(".
    guard expectPeekAndContinue(.lParen) else { return nil }

    // After this call, currentToken is the first character of the condition.
    moveToNextToken()

    guard let condition = parseExpression(withPrecedence: .lowest) else {
      errors.append("IfExpression: Unable to parse the condition.")
      return nil
    }

    // After this call, the currentToken is the ) of the condition.
    guard expectPeekAndContinue(.rParen) else {
      errors.append("IfExpression: Didn't find the closing `)` for the condition.")
      return nil
    }
    // After this call, the currentToken is the { of the consequence block.
    guard expectPeekAndContinue(.lBrace) else {
      errors.append("IfExpression: Didn't find the opening `{` for the consequence block.")
      return nil
    }

    guard let consequence = parseBlockStatement() else {
      errors.append("IfExpression: Unable to parse the `BlockStatement` for the consequence block.")
      return nil
    }

    if peekTokenIs(.else) {
      moveToNextToken()
      guard expectPeekAndContinue(.lBrace) else {
        errors.append("IfExpression: Didn't find the opening `{` for the alternative block.")
        return nil
      }

      guard let alt = parseBlockStatement() else {
        errors.append("IfExpression: Unable to parse the `BlockStatement` for the alternative block.")
        return nil
      }

      let ifElseExpr = IfExpression(
        token: token,
        condition: condition,
        consequence: consequence,
        alternative: alt)
      return ifElseExpr

    } else {
      let ifExpr = IfExpression(token: token, condition: condition, consequence: consequence)
      return ifExpr
    }
  }


  private func parseBlockStatement() -> BlockStatement? {
    guard currentTokenIs(.lBrace) else {
      return nil
    }

    let t = currentToken // Points to "{"
    var statements: [Statement] = []

    moveToNextToken()

    while !currentTokenIs(.rBrace) && !currentTokenIs(.eof) {
      if let stmt = parseStatement() {
        statements.append(stmt)
      }
      moveToNextToken()
    }

    let blockStmt = BlockStatement(token: t, statements: statements)
    return blockStmt
  }



  /// Parses a `LetStatement` starting from the current token.
  private func parseLetStatement() -> LetStatement? {
    guard currentTokenIs(.let) else { return nil }

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


  private func parseIdentifer() -> Expression? {
    assert(currentTokenIs(.ident))
    return Identifier(token: self.currentToken, value: self.currentToken.literal)
  }


  private func parseIntegerLiteral() -> Expression? {
    assert(currentTokenIs(.int))
    guard let intValue = Int(currentToken.literal) else {
      fatalError("Unable to parse integer from the value. Got=\(currentToken.literal)")
    }
    return IntegerLiteral(token: self.currentToken, value: intValue)
  }


  /// Parses a prefix expression.
  private func parsePrefixExpression() -> Expression? {
    assert(currentTokenIs(.bang) || currentTokenIs(.minus))

    let token = currentToken
    let prefixOperator = currentToken.literal

    moveToNextToken()

    guard let rightExpression = parseExpression(withPrecedence: .prefix) else {
      errors.append("Unable to parse the right expression for the Prefix Expression.")
      return nil
    }

    let expr = PrefixExpression(
      token: token,
      prefixOperator: prefixOperator,
      rightExpression: rightExpression)
    return expr
  }


  /// Parses an infix expression.
  private func parseInfixExpression(left: Expression?) -> Expression? {
    guard let leftExpr = left else {
      return nil
    }
    let token = currentToken
    let infixOperator = currentToken.literal
    let precedence = currentPrecedence()

    moveToNextToken()

    guard let right = parseExpression(withPrecedence: precedence) else {
      errors.append("Unable to parse the right expression for the Infix Expression.")
      return nil
    }

    let expr = InfixExpression(
      token: token,
      leftExpression: leftExpr,
      infixOperator: infixOperator,
      rightExpression: right)
    return expr
  }


  private func parseBoolean() -> Expression? {
    assert(currentTokenIs(.true) || currentTokenIs(.false))
    return Boolean(token: currentToken, value: currentTokenIs(.true))
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
  /// tokens and returns `true`. If the `peekToken` is not of the expected type, log an error
  /// and return `false`.
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
    return currentToken.isType(tokenType)
  }

  private func peekTokenIs(_ tokenType: TokenType) -> Bool {
    guard let peekT = peekToken else {
      return false
    }
    return peekT.isType(tokenType)
  }

  private func peekPrecedence() -> Precedence {
    return precedenceMapper.precedence(for: peekToken)
  }

  private func currentPrecedence() -> Precedence {
    return precedenceMapper.precedence(for: currentToken)
  }


  private func prefixParseFn(for token: Token?) -> PrefixParseFn? {
    guard let t = token else {
      return nil
    }
    return prefixParseFunctions[t.type]
  }


  private func infixParseFn(for token: Token?) -> InfixParseFn? {
    guard let t = token else {
      return nil
    }
    return infixParseFunctions[t.type]
  }


  private func noPrefixParseFnError(_ tokenType: TokenType) {
    let msg = "No prefix parse function for `\(tokenType)` found."
    errors.append(msg)
  }


  private func peekError(_ tokenType: TokenType) {
    let s = peekToken == nil ? "nil" : "\(peekToken!.type)"
    let message = "peekError: Expected next token to be \(tokenType), got \(s) instead."
    errors.append(message)
  }
}
