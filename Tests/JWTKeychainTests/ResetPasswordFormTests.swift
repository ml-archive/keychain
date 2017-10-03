import XCTest

class ResetPasswordFormTests: TestCase {
    func testResetPasswordForm() throws {
        let token = try createToken()
        try drop
            .testResponse(to: .get, at: "users/reset-password/form/\(token)")
            .assertStatus(is: .ok)
        
        XCTAssertEqual(drop.capturedViewPath, "JWTKeychain/ResetPassword/resetPassword")
        XCTAssertEqual(drop.capturedViewData?["token"]?.string, token)
        XCTAssertNotNil(drop.capturedViewData?["request"])

        let fieldset = drop.capturedViewData?["fieldset"]
        XCTAssertEqual(fieldset?["email"], ["label": "Email"])
        XCTAssertEqual(fieldset?["password"], ["label": "Password"])
        XCTAssertEqual(
            fieldset?["passwordRepeat"],
            ["label": "Repeat Password"]
        )
    }
}
