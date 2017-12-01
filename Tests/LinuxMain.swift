#if os(Linux)

import XCTest
@testable import JWTKeychainTests

// sourcery:inline:auto:LinuxMain

extension ResetPasswordChangeTests {
  static var allTests = [
    ("testMissingUser", testMissingUser),
    ("testInvalidPassword", testInvalidPassword),
    ("testDifferentPasswords", testDifferentPasswords),
    ("testInvalidToken", testInvalidToken),
    ("testMismatchingPasswordVersion", testMismatchingPasswordVersion),
    ("testExistingUser", testExistingUser),
  ]
}

extension ResetPasswordFormTests {
  static var allTests = [
    ("testResetPasswordForm", testResetPasswordForm),
  ]
}

extension SettingsTests {
  static var allTests = [
    ("testCreatingSettingsFromConfig", testCreatingSettingsFromConfig),
    ("testCreatingSettingsFromMinimalConfig", testCreatingSettingsFromMinimalConfig),
  ]
}

XCTMain([
  testCase(ResetPasswordChangeTests.allTests),
  testCase(ResetPasswordFormTests.allTests),
  testCase(SettingsTests.allTests),
])

// sourcery:end

#endif

