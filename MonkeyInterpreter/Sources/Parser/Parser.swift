// Created on 10/25/23.

import Foundation
import Lexer
import Token
import AST


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
    registerPrefix(for: .string, fn: parseStringLiteral)
    registerPrefix(for: .bang, fn: parsePrefixExpression)
    registerPrefix(for: .minus, fn: parsePrefixExpression)
    registerPrefix(for: .true, fn: parseBooleanLiteral)
    registerPrefix(for: .false, fn: parseBooleanLiteral)
    registerPrefix(for: .lParen, fn: parseGroupedExpression)
    registerPrefix(for: .if, fn: parseIfExpression)
    registerPrefix(for: .function, fn: parseFunctionLiteral)
    registerPrefix(for: .lBracket, fn: parseArrayLiteral)
    registerPrefix(for: .lBrace, fn: parseDictionaryLiteral)

    registerInfix(for: .plus, fn: parseInfixExpression(left:))
    registerInfix(for: .minus, fn: parseInfixExpression(left:))
    registerInfix(for: .asterisk, fn: parseInfixExpression(left:))
    registerInfix(for: .slash, fn: parseInfixExpression(left:))
    registerInfix(for: .lt, fn: parseInfixExpression(left:))
    registerInfix(for: .gt, fn: parseInfixExpression(left:))
    registerInfix(for: .eq, fn: parseInfixExpression(left:))
    registerInfix(for: .notEq, fn: parseInfixExpression(left:))
    registerInfix(for: .lParen, fn: parseCallExpression(left:))
    registerInfix(for: .lBracket, fn: parseIndexExpression(left:))
  }



  // MARK: - Public

  public func parseProgram() -> Program? {
    let program = Program()

    while currentToken.type != .eof, let statement = parseStatement() {
      program.appendStatement(statement)
      incrementTokens()
    }
    return program
  }


  public func registerPrefix(for tokenType: TokenType, fn: @escaping PrefixParseFn) {
    prefixParseFunctions[tokenType] = fn
  }

  public func registerInfix(for tokenType: TokenType, fn: @escaping InfixParseFn) {
    infixParseFunctions[tokenType] = fn
  }


  // MARK: - Private (Parse Literals)


  /// Parses an `ArrayLiteral` starting from the current token.
  private func parseArrayLiteral() -> ArrayLiteral? {
    guard currentTokenIs(.lBracket) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    let t = currentToken
    let elements = parseExpressionList(startingAt: .lBracket, terminatingAt: .rBracket)
    return ArrayLiteral(token: t, elements: elements)
  }


  private func parseDictionaryLiteral() -> DictionaryLiteral? {
    guard currentTokenIs(.lBrace) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    let t = currentToken
    var pairs: [DictionaryEntity] = []

    while !peekTokenIs(.rBrace) {
      incrementTokens()
      guard let key = parseExpression(withPrecedence: .lowest) else {
        errors.append("\(#function): Unable to parse the expression for key.")
        return nil
      }
      guard expectPeekAndIncrement(.colon) else {
        return nil
      }

      incrementTokens()
      guard let value = parseExpression(withPrecedence: .lowest) else {
        errors.append("\(#function): Unable to parse the expression for value.")
        return nil
      }

      pairs.append(DictionaryEntity(key: key, value: value))

      if !peekTokenIs(.rBrace) && !expectPeekAndIncrement(.comma) {
        return nil
      }
    }

    if !expectPeekAndIncrement(.rBrace) {
      return nil
    }

    return DictionaryLiteral(token: t, pairs: pairs)
  }


  /// Parses a `Boolean` starting from the current token.
  private func parseBooleanLiteral() -> BooleanLiteral? {
    guard currentTokenIs(.true) || currentTokenIs(.false) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }
    return BooleanLiteral(token: currentToken, value: currentTokenIs(.true))
  }


  /// Parses an `IntegerLiteral` starting from the current token.
  private func parseIntegerLiteral() -> IntegerLiteral? {
    guard currentTokenIs(.int) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }
    guard let intValue = Int(currentToken.literal) else {
      fatalError("\(#function): Unable to parse integer from the value. Got=\(currentToken.literal)")
    }
    return IntegerLiteral(token: self.currentToken, value: intValue)
  }


  /// Parses a `StringLiteral` starting from the current token.
  private func parseStringLiteral() -> StringLiteral? {
    guard currentTokenIs(.string) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    let strValue = currentToken.literal
    return StringLiteral(token: self.currentToken, value: strValue)
  }


  // MARK: - Private (Parse Statements)


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


  /// Parses a `LetStatement` starting from the current token.
  private func parseLetStatement() -> LetStatement? {
    guard currentTokenIs(.let) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    let t = currentToken

    // Parse the name.
    guard expectPeekAndIncrement(.ident) else { return nil }
    let nameIdentifier = Identifier(token: currentToken, value: currentToken.literal)

    // Parse the assignment operator.
    guard expectPeekAndIncrement(.assign) else { return nil }

    incrementTokens()

    guard let expr = parseExpression(withPrecedence: .lowest) else {
      errors.append("\(#function): Unable to parse the expression.")
      return nil
    }

    if peekTokenIs(.semicolon) {
      incrementTokens()
    }

    let stmt = LetStatement(token: t, name: nameIdentifier, value: expr)
    return stmt
  }


  /// Parses a `ReturnStatement` starting from the current token.
  private func parseReturnStatement() -> ReturnStatement? {
    guard currentTokenIs(.return) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    let t = currentToken
    if peekTokenIs(.semicolon) {
      incrementTokens()
      return ReturnStatement(token: t)
    } else {
      incrementTokens()
      let returnValue = parseExpression(withPrecedence: .lowest)

      if peekTokenIs(.semicolon) {
        incrementTokens()
      }

      let stmt = ReturnStatement(token: t, returnValue: returnValue)
      return stmt
    }
  }


  /// Parses an `ExpressionStatement` starting from the current token.
  private func parseExpressionStatement() -> ExpressionStatement? {
    let stmt = ExpressionStatement(
      token: currentToken,
      expression: parseExpression(withPrecedence: .lowest))

    if peekTokenIs(.semicolon) {
      incrementTokens()
    }
    return stmt
  }


  /// Parses a `BlockStatement` starting from the current token.
  private func parseBlockStatement() -> BlockStatement? {
    guard currentTokenIs(.lBrace) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    let t = currentToken // Points to "{"
    var statements: [Statement] = []

    incrementTokens()

    while !currentTokenIs(.rBrace) && !currentTokenIs(.eof) {
      if let stmt = parseStatement() {
        statements.append(stmt)
      }
      incrementTokens()
    }

    let blockStmt = BlockStatement(token: t, statements: statements)
    return blockStmt
  }


  // MARK: - Private (Parse Expressions)


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

      incrementTokens()
      leftExp = infixFn(leftExp)
    }
    return leftExp
  }


  /// Parse grouped expressions, i.e. expressions grouped by parenthesis.
  private func parseGroupedExpression() -> Expression? {
    guard currentTokenIs(.lParen) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    incrementTokens()
    let expr = parseExpression(withPrecedence: .lowest)

    guard expectPeekAndIncrement(.rParen) else {
      return nil
    }
    return expr
  }


  /// Parses an `IfExpression` starting from the current token.
  private func parseIfExpression() -> Expression? {
    guard currentTokenIs(.if) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    let token = currentToken // the `if`.

    // After this call, currentToken is "(".
    guard expectPeekAndIncrement(.lParen) else { return nil }

    // After this call, currentToken is the first character of the condition.
    incrementTokens()

    guard let condition = parseExpression(withPrecedence: .lowest) else {
      errors.append("\(#function): Unable to parse the condition.")
      return nil
    }

    // After this call, the currentToken is the ) of the condition.
    guard expectPeekAndIncrement(.rParen) else {
      errors.append("\(#function): Didn't find the closing `)` for the condition.")
      return nil
    }
    // After this call, the currentToken is the { of the consequence block.
    guard expectPeekAndIncrement(.lBrace) else {
      errors.append("v: Didn't find the opening `{` for the consequence block.")
      return nil
    }

    guard let consequence = parseBlockStatement() else {
      errors.append("\(#function): Unable to parse the `BlockStatement` for the consequence block.")
      return nil
    }

    if peekTokenIs(.else) {
      incrementTokens()
      guard expectPeekAndIncrement(.lBrace) else {
        errors.append("\(#function): Didn't find the opening `{` for the alternative block.")
        return nil
      }

      guard let alt = parseBlockStatement() else {
        errors.append("\(#function): Unable to parse the `BlockStatement` for the alternative block.")
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


  /// Parses an `Identifer` starting from the current token.
  private func parseIdentifer() -> Identifier? {
    guard currentTokenIs(.ident) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }
    return Identifier(token: self.currentToken, value: self.currentToken.literal)
  }


  /// Parses a `PrefixExpression` starting from the current token.
  private func parsePrefixExpression() -> PrefixExpression? {
    guard currentTokenIs(.bang) || currentTokenIs(.minus) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    let token = currentToken
    let prefixOperator = currentToken.literal

    incrementTokens()

    guard let rightExpression = parseExpression(withPrecedence: .prefix) else {
      errors.append("\(#function): Unable to parse the right expression for the Prefix Expression.")
      return nil
    }

    let expr = PrefixExpression(
      token: token,
      prefixOperator: prefixOperator,
      rightExpression: rightExpression)
    return expr
  }


  /// Parses an `InfixExpression` starting from the current token.
  private func parseInfixExpression(left: Expression?) -> InfixExpression? {
    guard let leftExpr = left else {
      return nil
    }
    let token = currentToken
    let infixOperator = currentToken.literal
    let precedence = currentPrecedence()

    incrementTokens()

    guard let right = parseExpression(withPrecedence: precedence) else {
      errors.append("\(#function): Unable to parse the right expression for the Infix Expression.")
      return nil
    }

    let expr = InfixExpression(
      token: token,
      leftExpression: leftExpr,
      infixOperator: infixOperator,
      rightExpression: right)
    return expr
  }


  private func parseIndexExpression(left: Expression?) -> IndexExpression? {
    guard let leftExpr = left else { return nil }

    guard currentTokenIs(.lBracket) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    let t = currentToken
    incrementTokens()
    guard let index = parseExpression(withPrecedence: .lowest) else {
      errors.append("\(#function): Could not parse the body of the function.")
      return nil
    }

    if !expectPeekAndIncrement(.rBracket) {
      return nil
    }
    return IndexExpression(token: t, left: leftExpr, index: index)
  }


  /// Parses a list of expressions separated by commas. E.g. arguments in function, or
  /// elements in an array.
  private func parseExpressionList(
    startingAt startToken: TokenType,
    terminatingAt endToken: TokenType
  ) -> [Expression] {

    guard currentTokenIs(startToken) else {
      errors.append(
        "\(#function): Invalid starting token. Got=\(currentToken.type), Want=\(startToken)")
      return []
    }

    incrementTokens()

    var tokens: [Expression] = []
    while !currentTokenIs(endToken) && !currentTokenIs(.eof) {
      if let arg = parseExpression(withPrecedence: .lowest) {
        tokens.append(arg)
      }
      incrementTokens()
      if currentTokenIs(.comma) {
        incrementTokens()
      }
    }

    if !currentTokenIs(endToken) {
      return []
    }

    return tokens
  }


  // MARK: - Private (Parse Functions)


  /// Parses a `FunctionLiteral` starting from the current token.
  private func parseFunctionLiteral() -> FunctionLiteral? {
    guard currentTokenIs(.function) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }

    let t = currentToken // Points to "fn"

    guard expectPeekAndIncrement(.lParen) else {
      errors.append("\(#function): Didn't find the opening `(` for the function.")
      return nil
    }

    let parameters = parseFunctionParameters()

    guard expectPeekAndIncrement(.lBrace) else {
      errors.append("\(#function): Didn't find the opening `{` for the function's body.")
      return nil
    }

    guard let body = parseBlockStatement() else {
      errors.append("\(#function): Could not parse the body of the function.")
      return nil
    }

    let functionLiteral = FunctionLiteral(token: t, parameters: parameters, body: body)
    return functionLiteral
  }


  /// Parses the parameters for a function.
  private func parseFunctionParameters() -> [Identifier] {
    guard currentTokenIs(.lParen) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return []
    }

    incrementTokens()

    var parameters: [Identifier] = []
    while !currentTokenIs(.rParen) && !currentTokenIs(.eof) {
      if let p = parseIdentifer() {
        parameters.append(p)
      }
      incrementTokens()
      if currentTokenIs(.comma) {
        incrementTokens()
      }
    }
    return parameters
  }


  /// Parses a `CallExpression` starting from the current token.
  private func parseCallExpression(left: Expression?) -> CallExpression? {
    guard currentTokenIs(.lParen) else {
      errors.append("\(#function): Invalid starting token. Got=\(currentToken.type)")
      return nil
    }
    guard let function = left else {
      errors.append("\(#function): function expression is nil.")
      return nil
    }

    let t = currentToken
    let arguments = parseExpressionList(startingAt: .lParen, terminatingAt: .rParen)
    let callExpr = CallExpression(token: t, function: function, arguments: arguments)
    return callExpr
  }


  // MARK: - Private (Helpers)


  /// Helper function that advances both the token pointers.
  private func incrementTokens() {
    guard let pT = peekToken else {
      fatalError("Invoked incrementToken when `peekToken` is nil.")
    }
    currentToken = pT
    peekToken = lexer.nextToken()
  }


  /// Validates that the `peekToken` is of the expected type. If so, it increments the two
  /// tokens and returns `true`. If the `peekToken` is not of the expected type, log an error
  /// and return `false`.
  private func expectPeekAndIncrement(_ tokenType: TokenType) -> Bool {
    if peekTokenIs(tokenType) {
      incrementTokens()
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
