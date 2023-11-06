# Swift-Monkey-Interpreter


This repo is the Swift implementation of the interpreter for the Monkey language. This interpreter is described in the book, [Writing an Interpreter in Go](https://interpreterbook.com) by Thorsten Ball ([@mrnugget](https://github.com/mrnugget) on GitHub).

## Running the Project
### Xcode
Download this project. In Xcode, go to `File` -> `Open`, and open the root level directory for this repo. The entire project should open up in Xcode.

### Command Line
Download this project. From the root  directory, run the following set of commands:

```shell
# Start up the monkey REPL
$ swift run

# Run all the unit tests.
$ swift test

# Run individual test suites.
$ swift test --filter LexerTests
$ swift test --filter ObjectTests
$ swift test --filter ParserTests
$ swift test --filter ASTTests
$ swift test --filter EvaluatorTests
```

## Building a binary
To build the release version of the binary, run the command:

```
$ swift build -c release
```

This builds and creates an executable named `monkey` in the  `MonkeyInterpreter/.build/release` folder.
