import Authentication
import JWT
import SMTP
import Testing
import Vapor
import XCTest
@testable import JWTKeychain

final class UserControllerTests: XCTestCase {
    var mailer: TestMailer!
    var signer: TestSigner!
    var user: TestUser!
    var userAuthenticator: TestUserAuthenticator!
    var userController: UserController<TestUserAuthenticator>!

    override class func setUp() {
        Testing.onFail = XCTFail
    }

    override func setUp() {
        mailer = TestMailer()
        signer = TestSigner()
        user = TestUser(
            email: "a@b.com",
            hashedPassword: "hashedpassword",
            token: Token(string: "token")
        )
        userAuthenticator = TestUserAuthenticator(user: user)
        userController = UserController(
            mailer: mailer,
            // use the same reference date to produce reliable test output
            now: { Date.init(timeIntervalSince1970: 0) },
            signer: signer,
            userAuthenticator: userAuthenticator
        )
    }

    func testRegister() throws {
        try checkUserControllerAction(
            userController.register,
            expectedAction: "make(request:)",
            expectedJSONValues: [
                "accessToken": "eyJhbGciOiJUZXN0U2lnbmVyIiwidHlwIjoiSldUIn0.eyJub2Rlczpwd2QiOiJoYXNoZWRwYXNzd29yZCIsImV4cCI6MzYwMCwic3ViIjoiMSJ9.dGVzdFNpZ25hdHVyZQ",
                "refreshToken": "eyJhbGciOiJUZXN0U2lnbmVyIiwidHlwIjoiSldUIn0.eyJub2Rlczpwd2QiOiJoYXNoZWRwYXNzd29yZCIsImV4cCI6MzE1MzYwMDAsInN1YiI6IjEifQ.dGVzdFNpZ25hdHVyZQ",
                "user": user
            ]
        )
    }

    func testLogIn() throws {
        try checkUserControllerAction(
            userController.logIn,
            expectedAction: "logIn(request:)",
            expectedJSONValues: [
                "accessToken": "eyJhbGciOiJUZXN0U2lnbmVyIiwidHlwIjoiSldUIn0.eyJub2Rlczpwd2QiOiJoYXNoZWRwYXNzd29yZCIsImV4cCI6MzYwMCwic3ViIjoiMSJ9.dGVzdFNpZ25hdHVyZQ",
                "refreshToken": "eyJhbGciOiJUZXN0U2lnbmVyIiwidHlwIjoiSldUIn0.eyJub2Rlczpwd2QiOiJoYXNoZWRwYXNzd29yZCIsImV4cCI6MzE1MzYwMDAsInN1YiI6IjEifQ.dGVzdFNpZ25hdHVyZQ",
                "user": user
            ]
        )
    }

    func testLogOut() throws {
        try checkUserControllerAction(
            userController.logOut,
            expectedAction: "logOut(request:)",
            expectedJSONValues: ["status": "ok"]
        )
    }

    func testRegenerate() throws {
        try checkUserControllerAction(
            { request in
                request.auth.authenticate(user)
                return try userController.regenerate(request: request)
            },
            expectedJSONValues: ["accessToken": "eyJhbGciOiJUZXN0U2lnbmVyIiwidHlwIjoiSldUIn0.eyJub2Rlczpwd2QiOiJoYXNoZWRwYXNzd29yZCIsImV4cCI6MzYwMCwic3ViIjoiMSJ9.dGVzdFNpZ25hdHVyZQ"]
        )
    }

    func testMe() throws {
        try checkUserControllerAction(
            { request in
                request.auth.authenticate(user)
                return try userController.me(request: request)
            },
            expectedJSONValues: ["user": user]
        )
    }

    func testResetPasswordEmail() throws {
        try checkUserControllerAction(
            userController.resetPasswordEmail,
            expectedAction: "find(request:)",
            expectedJSONValues: ["status": "Instructions were sent to the provided email"]
        )
        XCTAssertEqual(mailer.subject, "Reset Password")
        XCTAssertEqual(mailer.accessToken?.string, "eyJhbGciOiJUZXN0U2lnbmVyIiwidHlwIjoiSldUIn0.eyJub2Rlczpwd2QiOiJoYXNoZWRwYXNzd29yZCIsImV4cCI6MzYwMCwic3ViIjoiMSJ9.dGVzdFNpZ25hdHVyZQ")
        XCTAssertEqual(mailer.user as? TestUser, user)
    }

    func testUpdate() throws {
        try checkUserControllerAction(
            userController.update,
            expectedAction: "update(request:)",
            expectedJSONValues: ["user": user]
        )
    }

    static var allTests = [
        ("testRegister", testRegister),
        ("testLogIn", testLogIn),
        ("testLogOut", testLogOut),
        ("testRegenerate", testRegenerate),
        ("testMe", testMe),
        ("testResetPasswordEmail", testResetPasswordEmail),
        ("testUpdate", testUpdate)
    ]
}

extension UserControllerTests {
    func checkUserControllerAction(
        _ handleRequest: ((Request) throws -> ResponseRepresentable),
        expectedAction: String? = nil,
        expectedJSONValues: [String: NodeRepresentable],
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let response = try handleRequest(.makeTest(method: .get)).makeResponse()

        if let action = expectedAction {
            XCTAssertEqual(userAuthenticator.action, action, file: file, line: line)
        }

        try expectedJSONValues.forEach {
            try response.assertJSON($0.0, equals: $0.1, file: file, line: line)
        }
    }
}
