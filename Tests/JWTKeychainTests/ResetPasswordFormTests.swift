import XCTest

class ResetPasswordFormTests: TestCase {
    func testResetPasswordForm() throws {
        let token = try createToken()
        try drop
            .testResponse(to: .get, at: "/users/reset-password/form/\(token)")
            .assertStatus(is: .ok)
        
        XCTAssertEqual(drop.capturedViewPath, "ResetPassword/resetPassword")
        XCTAssertEqual(drop.capturedViewData?["token"]?.string, token)
        XCTAssertNotNil(drop.capturedViewData?["request"])
        
        let fielddet = drop.capturedViewData?["fieldset"]
        XCTAssertEqual(fielddet?["email"], ["label": "Email"])
        XCTAssertEqual(fielddet?["password"], ["label": "Password"])
        XCTAssertEqual(
            fielddet?["passwordConfirmation"],
            ["label": "Confirm Password"]
        )
    }
}
