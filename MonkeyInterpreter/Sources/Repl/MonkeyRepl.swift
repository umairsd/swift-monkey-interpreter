// Created on 10/24/23.

import Foundation
import Evaluator
import Lexer
import Object
import Parser

/// A simple REPL for the Monkey programming language.
public struct MonkeyRepl {
  private static let prompt = ">> "
  private static let monkeyFace = """
              __,__
     .--.  .-"     "-.  .--.
    / .. \\/  .-. .-.  \\/ .. \\
   | |  '|  /   Y   \\  |'  | |
   | \\   \\  \\ 0 | 0 /  /   / |
    \\ '- ,\\.-\""\""\""\"-./, -' /
     ''-' /_   ^ ^   _\\ '-''
         |  \\._   _./  |
         \\   \\ '~' /   /
          '._ '-=-' _.'
             '-----'
  """

  public init() {}

  public func start() {
    print(Self.prompt, terminator: "")

    let env = Environment()

    while let line = readLine() {
      defer {
        print(Self.prompt, terminator: "")
      }

      let lexer = Lexer(input: line)
      let parser = Parser(lexer: lexer)

      guard let program = parser.parseProgram() else {
        print("`parseProgram()` failed to parse the input.")
        continue
      }

      guard parser.errors.count == 0 else {
        printParseErrors(parser.errors)
        continue
      }

      let evaluated = Evaluator().eval(program, within: env)
      if let errorObj = evaluated as? ErrorObject {
        print("Error: Unable to evaluate the parsed program.")
        print("  \(errorObj.message)")
        continue
      }

      print(evaluated.inspect())
    }
  }

  private func printParseErrors(_ errors: [String]) {
    print(Self.monkeyFace)
    print("Whoops! We ran into some monkey business here!")
    print("  parser errors:")
    errors.forEach { print("\t\($0)") }
  }
}
