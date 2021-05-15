import XCTest

import CoreTests
import CoreUITests

var tests = [XCTestCaseEntry]()
tests += CoreTests.allTests()
tests += CoreUITests.allTests()
XCTMain(tests)
