// Created on 11/2/23.

import Foundation
import Object

/// A type that holds a static map of all the built-in functions supported by the Monkey
/// language.
public struct Builtins {

  public static let builtinMap: [String: BuiltinObject] = [
    "len" : BuiltinObject() { args in
      guard args.count == 1, let arg = args.first else {
        return ErrorObject(message: "Wrong number of arguments. Got=\(args.count), want=1")
      }

      switch arg {
      case let strObj as StringObject:
        return IntegerObject(value: strObj.value.count)

      default:
        return ErrorObject(message: "Argument to `len` not supported. Got=\(arg.type())")
      }
    }
  ]

}


