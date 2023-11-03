// Created on 11/3/23.

import XCTest
@testable import Object

final class ObjectTest: XCTestCase {

  func testStringHash() throws {
    let hello1 = StringObject(value: "Hello world!")
    let hello2 = StringObject(value: "Hello world!")
    let hello3 = StringObject(value: "Hello world")

    XCTAssertEqual(hello1, hello2)
    XCTAssertEqual(hello1.hashValue, hello2.hashValue)

    XCTAssertNotEqual(hello1, hello3)
    XCTAssertNotEqual(hello1.hashValue, hello3.hashValue)

    XCTAssertNotEqual(hello2, hello3)
    XCTAssertNotEqual(hello2.hashValue, hello3.hashValue)
  }


  func testIntegerHash() throws {
    let i1 = IntegerObject(value: 123)
    let i2 = IntegerObject(value: 123)
    let i3 = IntegerObject(value: 124)

    XCTAssertEqual(i1, i2)
    XCTAssertEqual(i1.hashValue, i2.hashValue)

    XCTAssertNotEqual(i1, i3)
    XCTAssertNotEqual(i1.hashValue, i3.hashValue)

    XCTAssertNotEqual(i2, i3)
    XCTAssertNotEqual(i2.hashValue, i3.hashValue)
  }


  func testBooleanHash() throws {
    let b1 = BooleanObject(value: true)
    let b2 = BooleanObject(value: true)
    let b3 = BooleanObject(value: false)

    XCTAssertEqual(b1, b2)
    XCTAssertEqual(b1.hashValue, b2.hashValue)

    XCTAssertNotEqual(b1, b3)
    XCTAssertNotEqual(b1.hashValue, b3.hashValue)

    XCTAssertNotEqual(b2, b3)
    XCTAssertNotEqual(b2.hashValue, b3.hashValue)
  }
}
