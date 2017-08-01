import HTTP
import JWT
import Testing
import Vapor
import XCTest
@testable import JWTKeychain

final class JWTKeychainTests: TestCase {
    let drop = try! Droplet.testable()
    
    func testResetPasswordForm() throws {
        let jwt = try JWT(
            headers: JSON(),
            payload: JSON(),
            signer: drop.assertSigner()
        )
        let token = try jwt.createToken()
        
        try drop
            .testResponse(to: .get, at: "/users/reset-password/form/\(token)")
            .assertStatus(is: .ok)
        
        XCTAssertEqual(drop.capturedViewPath, "ResetPassword/user-form")
        XCTAssertEqual(drop.capturedViewData?["token"]?.string, token)
        XCTAssertNotNil(drop.capturedViewData?["request"])
        
        let fieldSet = drop.capturedViewData?["fieldset"]
        XCTAssertEqual(fieldSet?["email"], ["label": "Email"])
        XCTAssertEqual(fieldSet?["password"], ["label": "Password"])
        XCTAssertEqual(
            fieldSet?["passwordConfirmation"],
            ["label": "Confirm Password"]
        )
    }
}
