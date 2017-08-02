import XCTest

class ResetPasswordFormTests: TestCase {
    func testResetPasswordForm() throws {
        let token = try createToken()
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
