// Generated using Sourcery 0.8.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


@testable import JWTKeychainTests
import XCTest

extension ResetPasswordChangeTests {
  static var allTests = [
    ("testMissingUser", testMissingUser),
    ("testInvalidEmail", testInvalidEmail),
    ("testInvalidPassword", testInvalidPassword),
    ("testDifferentPasswords", testDifferentPasswords),
    ("testInvalidToken", testInvalidToken),
    ("testMismatchingPasswordHash", testMismatchingPasswordHash),
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
