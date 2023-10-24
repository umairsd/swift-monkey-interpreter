// Created on 10/23/23.

import XCTest
@testable import Lexer

final class LexerTest: XCTestCase {

  func testNextToken_emptyString() throws {
    let input = ""
    let lexer = Lexer(input: input)
    XCTAssertEqual(lexer.nextToken().type, .eof)
  }


  func testNextToken_basic() throws {
    let input = "=+(){},;"

    let expectedTokens = [
      Token(type: .assign, literal: "="),
      Token(type: .plus, literal: "+"),
      Token(type: .lParen, literal: "("),
      Token(type: .rParen, literal: ")"),
      Token(type: .lBrace, literal: "{"),
      Token(type: .rBrace, literal: "}"),
      Token(type: .comma, literal: ","),
      Token(type: .semicolon, literal: ";"),
      Token(type: .eof, literal: ""),
    ]

    let lexer = Lexer(input: input)

    for expectedToken in expectedTokens {
      let token = lexer.nextToken()
      XCTAssertEqual(token.type, expectedToken.type)
      XCTAssertEqual(token.literal, expectedToken.literal)
    }
  }


  func testNextToken_basicWithWhitespace() throws {
    let input = "   =+(){},;   "

    let expectedTokens = [
      Token(type: .assign, literal: "="),
      Token(type: .plus, literal: "+"),
      Token(type: .lParen, literal: "("),
      Token(type: .rParen, literal: ")"),
      Token(type: .lBrace, literal: "{"),
      Token(type: .rBrace, literal: "}"),
      Token(type: .comma, literal: ","),
      Token(type: .semicolon, literal: ";"),
      Token(type: .eof, literal: ""),
    ]

    let lexer = Lexer(input: input)

    for expectedToken in expectedTokens {
      let token = lexer.nextToken()
      XCTAssertEqual(token.type, expectedToken.type)
      XCTAssertEqual(token.literal, expectedToken.literal)
    }
  }


  func testNextToken_assignment() throws {
    let input = "let five = fiveVar;"
    let lexer = Lexer(input: input)

    let expectedTokens = [
      Token(type: .`let`, literal: "let"),
      Token(type: .ident, literal: "five"),
      Token(type: .assign, literal: "="),
      Token(type: .ident, literal: "fiveVar"),
      Token(type: .semicolon, literal: ";"),
      Token(type: .eof, literal: ""),
    ]

    for expectedToken in expectedTokens {
      let token = lexer.nextToken()
      XCTAssertEqual(token.type, expectedToken.type)
      XCTAssertEqual(token.literal, expectedToken.literal)
    }
  }


  func testNextToken_assignmentInt() throws {
    let input = "let five = 5;"
    let lexer = Lexer(input: input)

    let expectedTokens = [
      Token(type: .`let`, literal: "let"),
      Token(type: .ident, literal: "five"),
      Token(type: .assign, literal: "="),
      Token(type: .int, literal: "5"),
      Token(type: .semicolon, literal: ";"),
      Token(type: .eof, literal: ""),
    ]

    for expectedToken in expectedTokens {
      let token = lexer.nextToken()
      XCTAssertEqual(token.type, expectedToken.type)
      XCTAssertEqual(token.literal, expectedToken.literal)
    }
  }
}
