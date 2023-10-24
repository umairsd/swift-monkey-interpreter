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


  func testNextToken_basic2() throws {
    let input = """
    !-/*5;
    5 < 10 > 5;
    """

    let lexer = Lexer(input: input)
    let expectedTokens = [
      Token(type: .bang, literal: "!"),
      Token(type: .minus, literal: "-"),
      Token(type: .slash, literal: "/"),
      Token(type: .asterisk, literal: "*"),
      Token(type: .int, literal: "5"),
      Token(type: .semicolon, literal: ";"),

      Token(type: .int, literal: "5"),
      Token(type: .lt, literal: "<"),
      Token(type: .int, literal: "10"),
      Token(type: .gt, literal: ">"),
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


  func testNextToken_programBasic() throws {
    let input = """
    if (5 < 10) {
     return true;
    } else {
     return false;
    }
    """

    let lexer = Lexer(input: input)
    let expectedTokens = [
      // if (5 < 10) {
      Token(type: .if, literal: "if"),
      Token(type: .lParen, literal: "("),
      Token(type: .int, literal: "5"),
      Token(type: .lt, literal: "<"),
      Token(type: .int, literal: "10"),
      Token(type: .rParen, literal: ")"),
      Token(type: .lBrace, literal: "{"),

      //  return true;
      Token(type: .return, literal: "return"),
      Token(type: .true, literal: "true"),
      Token(type: .semicolon, literal: ";"),

      // } else {
      Token(type: .rBrace, literal: "}"),
      Token(type: .else, literal: "else"),
      Token(type: .lBrace, literal: "{"),

      //  return false;
      Token(type: .return, literal: "return"),
      Token(type: .false, literal: "false"),
      Token(type: .semicolon, literal: ";"),

      // }
      Token(type: .rBrace, literal: "}"),

      Token(type: .eof, literal: ""),
    ]

    for expectedToken in expectedTokens {
      let token = lexer.nextToken()
      XCTAssertEqual(token.type, expectedToken.type)
      XCTAssertEqual(token.literal, expectedToken.literal)
    }
  }


  func testNextToken_programConditional() throws {
    let input = """
    let five = 5;
    let ten = 10;

    let add = fn(x, y) {
      x + y;
    };

    let result = add(five, ten);
    """

    let lexer = Lexer(input: input)
    let expectedTokens = [
      // let five = 5;
      Token(type: .`let`, literal: "let"),
      Token(type: .ident, literal: "five"),
      Token(type: .assign, literal: "="),
      Token(type: .int, literal: "5"),
      Token(type: .semicolon, literal: ";"),

      // let ten = 10;
      Token(type: .`let`, literal: "let"),
      Token(type: .ident, literal: "ten"),
      Token(type: .assign, literal: "="),
      Token(type: .int, literal: "10"),
      Token(type: .semicolon, literal: ";"),

      // let add = fn(x, y) {
      Token(type: .`let`, literal: "let"),
      Token(type: .ident, literal: "add"),
      Token(type: .assign, literal: "="),
      Token(type: .function, literal: "fn"),
      Token(type: .lParen, literal: "("),
      Token(type: .ident, literal: "x"),
      Token(type: .comma, literal: ","),
      Token(type: .ident, literal: "y"),
      Token(type: .rParen, literal: ")"),
      Token(type: .lBrace, literal: "{"),

      // x + y;
      Token(type: .ident, literal: "x"),
      Token(type: .plus, literal: "+"),
      Token(type: .ident, literal: "y"),
      Token(type: .semicolon, literal: ";"),

      // };
      Token(type: .rBrace, literal: "}"),
      Token(type: .semicolon, literal: ";"),

      // let result = add(five, ten);
      Token(type: .`let`, literal: "let"),
      Token(type: .ident, literal: "result"),
      Token(type: .assign, literal: "="),
      Token(type: .ident, literal: "add"),
      Token(type: .lParen, literal: "("),
      Token(type: .ident, literal: "five"),
      Token(type: .comma, literal: ","),
      Token(type: .ident, literal: "ten"),
      Token(type: .rParen, literal: ")"),
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
