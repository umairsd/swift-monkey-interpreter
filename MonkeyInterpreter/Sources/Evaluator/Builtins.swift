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

      case let arrayObj as ArrayObject:
        return IntegerObject(value: arrayObj.elements.count)

      default:
        return ErrorObject(message: "Argument to `len` not supported. Got \(arg.type())")
      }
    },

    /// Prints the passed in arguments.
    "puts" : BuiltinObject() { args in
      for arg in args {
        print(arg.inspect())
      }
      return OkObject()
    },

    /// Returns the first element of the input array.
    "first" : BuiltinObject() { args in
      guard args.count == 1, let arg = args.first else {
        return ErrorObject(message: "Wrong number of arguments. Got=\(args.count), want=1")
      }
      guard let arrayObj = args[0] as? ArrayObject else {
        return ErrorObject(message: "Argument to `first` must be array. Got \(args[0].type()).")
      }

      if let e =  arrayObj.elements.first {
        return e
      }

      return NullObject()
    },

    /// Returns the last element of the input array.
    "last" : BuiltinObject() { args in
      guard args.count == 1, let arg = args.first else {
        return ErrorObject(message: "Wrong number of arguments. Got=\(args.count), want=1")
      }
      guard let arrayObj = args[0] as? ArrayObject else {
        return ErrorObject(message: "Argument to `last` must be array. Got \(args[0].type()).")
      }

      if let e =  arrayObj.elements.last {
        return e
      }
      return NullObject()
    },

    /// Returns a new array by dropping the first element from the input array.
    "rest" : BuiltinObject() { args in
      guard args.count == 1, let arg = args.first else {
        return ErrorObject(message: "Wrong number of arguments. Got=\(args.count), want=1")
      }
      guard let arrayObj = args[0] as? ArrayObject else {
        return ErrorObject(message: "Argument to `rest` must be array. Got \(args[0].type()).")
      }

      if arrayObj.elements.count > 0 {
        let subArray = arrayObj.elements.dropFirst()
        return ArrayObject(elements: Array(subArray))
      }
      return NullObject()
    },

    /// Returns a new array by appending the given element to the end of the input array.
    "push" : BuiltinObject() { args in
      guard args.count == 2, let arg = args.first else {
        return ErrorObject(message: "Wrong number of arguments. Got=\(args.count), want=2")
      }
      guard let arrayObj = args[0] as? ArrayObject else {
        return ErrorObject(message: "Argument to `push` must be array. Got \(args[0].type()).")
      }

      var newArray = Array(arrayObj.elements)
      newArray.append(args[1])
      return ArrayObject(elements: newArray)
    },

  ]

}


