@testable import JWTKeychain
import Testing
import Vapor
import XCTest

final class ResetPasswordChangeTests: TestCase {
    var token: String!
    
    override func setUp() {
        super.setUp()
        try! User.makeQuery().forceDelete()
        token = try! createToken()
    }
    
    func testMissingUser() throws {
        try changePassword()
            .assertFlashType(is: .error, withMessage: "User not found.")
    }

    func testInvalidPassword() throws {
        let fieldset = try changePassword(
            password: "short",
            passwordRepeat: "short")
            .assertFlashType(is: .error, withMessage: validationFailedMessage)
            .fieldset
        
        let error = fieldset?["password"]?["errors"]?.array?.first?.string
        XCTAssertEqual(error, "Password is not strong enough.")
    }
    
    func testDifferentPasswords() throws {
        let user = try createUser()
        let token = try createToken(hashedPassword: user.hashedPassword!)
        let fieldset = try changePassword(
            token: token,
            passwordRepeat: "different")
            .assertFlashType(is: .error, withMessage: validationFailedMessage)
            .fieldset
        
        let error = fieldset?["passwordRepeat"]?["errors"]?.array?.first?
            .string
        XCTAssertEqual(error, "Passwords do not match.")
    }
    
    func testInvalidToken() throws {
        try changePassword(token: "invalid")
            .assertFlashType(is: .error, withMessage: "Invalid token.")
    }
    
    func testMismatchingPasswordHash() throws {
        try createUser()
        try changePassword()
            .assertFlashType(
                is: .error,
                withMessage: "Password already changed. Request another password reset to change it again."
        )
    }
    
    func testExistingUser() throws {
        let user = try createUser()
        let oldPassword = user.hashedPassword
        
        try changePassword(
            token: createToken(hashedPassword: strongPassword),
            password: "N3wp@ssword",
            passwordRepeat: "N3wp@ssword")
            .assertFlashType(
                is: .success,
                withMessage: "Password changed. You can close this page now."
        )
        
        XCTAssertNotEqual(try User.find(1)?.hashedPassword, oldPassword)
    }
}

// MARK: Constants

private let validationFailedMessage = "Please correct the highlighted fields below."
private let strongPassword = "$3cR34"
private let validEmail = "a@b.com"
private let validName = "name"

// MARK: Helper

extension ResetPasswordChangeTests {
    @discardableResult
    func createUser() throws -> User {
        let hasher = TestHasher()
        
        let user = try User(
            email: validEmail,
            name: validName,
            hashedPassword: hasher.make(strongPassword.bytes).makeString()
        )
        try user.save()
        return user
    }
    
    func changePassword(
        token: String? = nil,
        email: String? = validEmail,
        password: String? = strongPassword,
        passwordRepeat: String? = strongPassword
    ) throws -> Response {
        let token: String = token ?? self.token
        let request = Request.makeTest(
            method: .post,
            path: "/users/reset-password/change/\(token)")
        
        var body = JSON()
        try body.set("email", email)
        try body.set("password", password)
        try body.set("passwordRepeat", passwordRepeat)
        request.json = body
        
        let formPath = "/users/reset-password/form/\(token)"
        
        return try drop
            .testResponse(to: request)
            .assertStatus(is: .seeOther)
            .assertHeader(.location, contains: formPath)
    }
}
