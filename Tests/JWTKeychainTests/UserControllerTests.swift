import Authentication
import Fluent
import JWT
import SMTP
import Testing
import Vapor
import XCTest
@testable import JWTKeychain

struct TestTokenGenerator {
    let token: String
}

extension TestTokenGenerator: TokenGenerator {
    func generateToken<E>(
        for _: E
    ) throws -> Token where E : PasswordAuthenticatable, E: Entity {
        return Token(string: token)
    }
}

final class UserControllerTests: XCTestCase {
    var mailer: TestPaswordResetMailer!
    var user: TestUser!
    var userAuthenticator: TestUserAuthenticator!
    var userController: UserController<TestUserAuthenticator>!

    override class func setUp() {
        super.setUp()
        Testing.onFail = XCTFail
    }

    override func setUp() {
        super.setUp()
        
        mailer = TestPaswordResetMailer()

        user = TestUser(
            email: "a@b.com",
            hashedPassword: "hashedpassword",
            token: Token(string: "token")
        )
        userAuthenticator = TestUserAuthenticator(user: user)
        userController = UserController(
            passwordResetMailer: mailer,
            apiAccessTokenGenerator: TestTokenGenerator(token: "access"),
            refreshTokenGenerator: TestTokenGenerator(token: "refresh"),
            resetPasswordTokenGenerator: TestTokenGenerator(token: "reset"),
            userAuthenticator: userAuthenticator
        )
    }

    func testRegister() throws {
        try checkUserControllerAction(
            userController.register,
            expectedAction: "make(request:)",
            expectedJSONValues: [
                "accessToken": "access",
                "refreshToken": "refresh",
                "user": user
            ]
        )
    }

    func testLogIn() throws {
        try checkUserControllerAction(
            userController.logIn,
            expectedAction: "logIn(request:)",
            expectedJSONValues: [
                "accessToken": "access",
                "refreshToken": "refresh",
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
            expectedJSONValues: ["accessToken": "access"]
        )
    }

    func testMe() throws {
        try checkUserControllerAction(
            { request in
                request.auth.authenticate(user)
                return try userController.me(request: request)
            },
            expectedJSONValues: ["email": "a@b.com"]
        )
    }

    func testResetPasswordEmail() throws {
        try checkUserControllerAction(
            userController.resetPasswordEmail,
            expectedAction: "find(request:)",
            expectedJSONValues: ["status": "Instructions were sent to the provided email"]
        )
        XCTAssertEqual(mailer.capturedSubject, "Reset Password")
        XCTAssertEqual(mailer.capturedResetToken?.string, "reset")
        XCTAssertEqual(mailer.capturedUser as? TestUser, user)
    }

    func testUpdate() throws {
        try checkUserControllerAction(
            userController.update,
            expectedAction: "update(request:)",
            expectedJSONValues: ["email": "a@b.com"]
        )
    }
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
