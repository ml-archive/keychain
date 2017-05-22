import Authentication
import JWT
import SMTP
import Testing
import Vapor
import XCTest
@testable import JWTKeychain

final class UserControllerTests: XCTestCase {
    var hasher: TestHasher!
    var mailer: TestMailer!
    var signer: TestSigner!
    var user: TestUser!
    var userAuthenticator: TestUserAuthenticator!
    var userController: UserController<TestUserAuthenticator>!

    override class func setUp() {
        Testing.onFail = XCTFail
    }

    override func setUp() {
        hasher = TestHasher()
        mailer = TestMailer()
        signer = TestSigner()
        user = TestUser(email: "a@b.com", token: Token(string: "token"))
        userAuthenticator = TestUserAuthenticator(user: user)
        userController = UserController(
            hasher: hasher,
            mailer: mailer,
            signer: signer,
            userAuthenticator: userAuthenticator
        )
    }

    func testRegister() throws {
        try checkUserControllerAction(
            userController.register,
            expectedAction: "makeUser(request:hasher:)",
            expectedJSONValues: [
                "token": "token.signed",
                "user": user
            ]
        )
    }

    func testLogIn() throws {
        try checkUserControllerAction(
            userController.logIn,
            expectedAction: "logIn(request:)",
            expectedJSONValues: [
                "token": "token.signed",
                "user": user
            ]
        )
    }

    func testLogOut() throws {
        try checkUserControllerAction(
            userController.logOut,
            expectedAction: "logOut(request:)",
            expectedJSONValues: ["success": true]
        )
    }

    func testRegenerate() throws {
        try checkUserControllerAction(
            userController.regenerate,
            expectedAction: "findById(request:)",
            expectedJSONValues: ["token": "token.signed"]
        )
    }

    func testMe() throws {
        try checkUserControllerAction(
            userController.me,
            expectedAction: "findById(request:)",
            expectedJSONValues: ["user": user]
        )
    }

    func testResetPasswordEmail() throws {
        try checkUserControllerAction(
            userController.resetPasswordEmail,
            expectedAction: "findByEmail(request:)",
            expectedJSONValues: ["success": "Instructions were sent to the provided email"]
        )
        XCTAssertEqual(mailer.subject, "Reset Password")
        XCTAssertEqual(mailer.token?.string, "token.signed")
        XCTAssertEqual(mailer.user as? TestUser, user)
    }

    func testUpdate() throws {
        try checkUserControllerAction(
            userController.update,
            expectedAction: "update(request:hasher:)",
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
