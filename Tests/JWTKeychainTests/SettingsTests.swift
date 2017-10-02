@testable import JWTKeychain
import XCTest
import Vapor

class SettingsTests: XCTestCase {
    func testCreatingSettingsFromConfig() throws {
        var appConfig = try Config()
        try appConfig.set("url", "url")

        var jwtKeychainConfig = try Config()
        try jwtKeychainConfig.set("fromName", "name")
        try jwtKeychainConfig.set("fromAddress", "address")
        try jwtKeychainConfig.set("pathToEmailView", "/path/to/email/view")
        try jwtKeychainConfig.set("pathToFormView", "/path/to/form/view")
        try jwtKeychainConfig.set("apiPathPrefix", "api")
        try jwtKeychainConfig.set("frontendPathPrefix", "frontend")
        try jwtKeychainConfig.set("bCryptCost", 1)

        try jwtKeychainConfig.set(
            "apiAccess",
            ["kid": "access",
             "secondsToExpire": 1]
        )
        try jwtKeychainConfig.set(
            "refreshToken",
            ["kid": "refresh",
             "secondsToExpire": 2]
        )
        try jwtKeychainConfig.set(
            "resetPassword",
            ["kid": "reset",
             "secondsToExpire": 3]
        )

        var config = try Config()
        try config.set("app", appConfig)
        try config.set("jwt-keychain", jwtKeychainConfig)

        let settings = try Settings(config: config)

        XCTAssertEqual(settings.baseURL, "url")
        XCTAssertEqual(settings.pathToEmailView, "/path/to/email/view")
        XCTAssertEqual(settings.pathToFormView, "/path/to/form/view")
        XCTAssertEqual(settings.fromEmailAddress.address, "address")
        XCTAssertEqual(settings.fromEmailAddress.name, "name")
        XCTAssertEqual(settings.apiPathPrefix, "api")
        XCTAssertEqual(settings.frontendPathPrefix, "frontend")
        XCTAssertEqual(settings.apiAccess.kid, "access")
        XCTAssertEqual(settings.apiAccess.expireIn, 1.second)
        XCTAssertEqual(settings.refreshToken?.kid, "refresh")
        XCTAssertEqual(settings.refreshToken?.expireIn, 2.second)
        XCTAssertEqual(settings.resetPassword.kid, "reset")
        XCTAssertEqual(settings.resetPassword.expireIn, 3.second)
        XCTAssertEqual(settings.bCryptCost, 1)
    }

    func testCreatingSettingsFromMinimalConfig() throws {
        var appConfig = try Config()
        try appConfig.set("url", "url")

        var jwtKeychainConfig = try Config()
        try jwtKeychainConfig.set("fromName", "name")
        try jwtKeychainConfig.set("fromAddress", "address")

        var config = try Config()
        try config.set("app", appConfig)
        try config.set("jwt-keychain", jwtKeychainConfig)

        let settings = try Settings(config: config)

        XCTAssertEqual(settings.baseURL, "url")
        XCTAssertEqual(
            settings.pathToEmailView,
            "JWTKeychain/Emails/resetPassword")
        XCTAssertEqual(
            settings.pathToFormView,
            "JWTKeychain/Views/resetPassword")
        XCTAssertEqual(settings.fromEmailAddress.address, "address")
        XCTAssertEqual(settings.fromEmailAddress.name, "name")
        XCTAssertEqual(settings.apiPathPrefix, "api/users")
        XCTAssertEqual(settings.frontendPathPrefix, "users/reset-password")
        XCTAssertEqual(settings.apiAccess.kid, "access")
        XCTAssertEqual(settings.apiAccess.expireIn, 1.hour)
        XCTAssertNil(settings.refreshToken)
        XCTAssertEqual(settings.resetPassword.kid, "reset")
        XCTAssertEqual(settings.resetPassword.expireIn, 1.hour)
        XCTAssertNil(settings.bCryptCost)
    }
}
