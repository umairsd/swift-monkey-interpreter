// Created on 10/24/23.

import Foundation
import Lexer

/// A simple REPL for the Monkey programming language.
public struct MonkeyRepl {
  private static let prompt = ">> "

  public init() {}

  public func start() {
    print(Self.prompt, terminator: "")

    while let line = readLine() {
      let lexer = Lexer(input: line)
      var token = lexer.nextToken()

      while token.type != .eof {
        print(token)
        token = lexer.nextToken()
      }

      print(Self.prompt, terminator: "")
    }
  }
}
