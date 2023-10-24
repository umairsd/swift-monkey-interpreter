// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Repl

let userName = NSUserName()
print("Hello \(userName)! This is the Monkey programming language!")
print("Feel free to type in commands.")
print()

let repl = MonkeyRepl()
repl.start()

