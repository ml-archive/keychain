#if os(Linux)

import XCTest
@testable import JWTKeychainTests

// sourcery:inline:auto:LinuxMain

extension SettingsTests {
  static var allTests = [
    ("testPlaceholder", testPlaceholder),
  ]
}

XCTMain([
  testCase(SettingsTests.allTests),
])

// sourcery:end

#endif

