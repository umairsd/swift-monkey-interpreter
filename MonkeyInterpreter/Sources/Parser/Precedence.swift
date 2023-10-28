// Created on 10/27/23.

import Foundation
import Token


public enum Precedence: Int {
  case lowest = 0
  case equals // ==
  case lessGreater // < or >
  case sum // +
  case product // *
  case prefix // -x or !x
  case call // myFunction(x)
}
