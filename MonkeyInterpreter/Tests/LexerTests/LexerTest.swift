// Created on 10/23/23.

import XCTest
@testable import Lexer

final class LexerTest: XCTestCase {

  func testNextToken_emptyString() throws {
    let input = ""
    let lexer = Lexer(input: input)
    XCTAssertEqual(lexer.nextToken().type, .eof)
  }


  func testNextToken() throws {
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
}
