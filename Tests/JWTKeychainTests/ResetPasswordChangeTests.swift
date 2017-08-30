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
    
    func testInvalidEmail() throws {
        let fieldSet = try changePassword(email: "invalid")
            .assertFlashType(is: .error, withMessage: validationFailedMessage)
            .fieldSet
        
        let error = fieldSet?["email"]?["errors"]?.array?.first?.string
        XCTAssertEqual(error, "invalid is not a valid email")
    }
    
    func testInvalidPassword() throws {
        let fieldSet = try changePassword(
            password: "short",
            passwordConfirmation: "short")
            .assertFlashType(is: .error, withMessage: validationFailedMessage)
            .fieldSet
        
        let error = fieldSet?["password"]?["errors"]?.array?.first?.string
        XCTAssertEqual(error, "Not strong password")
    }
    
    func testDifferentPasswords() throws {
        let fieldSet = try changePassword(passwordConfirmation: "different")
            .assertFlashType(is: .error, withMessage: validationFailedMessage)
            .fieldSet
        
        let error = fieldSet?["passwordConfirmation"]?["errors"]?.array?.first?
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
        let oldPassword = user.password
        
        try changePassword(
            token: createToken(password: strongPassword),
            password: "N3wp@ssword",
            passwordConfirmation: "N3wp@ssword")
            .assertFlashType(
                is: .success,
                withMessage: "Password changed. You can close this page now."
        )
        
        XCTAssertNotEqual(try User.find(1)?.password, oldPassword)
    }
}

// MARK: Constants

private let validationFailedMessage = "Please correct the highlighted fields below."
private let strongPassword = "$3cR34"
private let validEmail = "a@b.com"

// MARK: Helper

extension ResetPasswordChangeTests {
    @discardableResult
    func createUser() throws -> User {
        let hasher = TestHasher()
        
        let user = try User(
            email: Valid<UniqueEmail>(validEmail),
            name: nil,
            password: hasher.hash(Valid(strongPassword))
        )
        try user.save()
        return user
    }
    
    func changePassword(
        token: String? = nil,
        email: String? = validEmail,
        password: String? = strongPassword,
        passwordConfirmation: String? = strongPassword
    ) throws -> Response {
        let token: String = token ?? self.token
        let request = Request.makeTest(
            method: .post,
            path: "/users/reset-password/change/\(token)")
        
        var body = JSON()
        try body.set("email", email)
        try body.set("password", password)
        try body.set("passwordConfirmation", passwordConfirmation)
        request.json = body
        
        let formPath = "/users/reset-password/form/\(token)"
        
        return try drop
            .testResponse(to: request)
            .assertStatus(is: .seeOther)
            .assertHeader(.location, contains: formPath)
    }
}
