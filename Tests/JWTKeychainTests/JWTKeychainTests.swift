@testable import JWTKeychain
import Vapor
import JWT
import XCTVapor

final class JWTKeychainTests: XCTestCase {
    var app: Application!

    override func setUp() {
        app = Application(.testing)
        app.keychain.configure(
            signer: JWTSigner(
                algorithm: TestJWTAlgorithm(name: UserAccessKeychainConfig.jwkIdentifier.string)
            ),
            config: UserAccessKeychainConfig()
        )
        app.keychain.configure(
            signer: JWTSigner(
                algorithm: TestJWTAlgorithm(name: UserRefreshKeychainConfig.jwkIdentifier.string)
            ),
            config: UserRefreshKeychainConfig()
        )
        app.keychain.configure(
            signer: JWTSigner(
                algorithm: TestJWTAlgorithm(name: UserResetKeychainConfig.jwkIdentifier.string)
            ),
            config: UserResetKeychainConfig()
        )
        app.passwords.use(TestHasher.init)
        try! app.register(collection: UserController(currentDate: { Date.init(timeIntervalSince1970: 0) }))
    }

    override func tearDown() {
        app.shutdown()
        app = nil
    }

    func test_login() throws {
        app.users.testUser = .test
        try app.test(.POST, "login", beforeRequest: { request in
            try request.content.encode(["password": "secret"], as: .json)
        }) { response in
            XCTAssertEqual(response.status, .ok)

            // test user response
            let loginResponse = try response.content.decode(TestAuthenticationResponse.self)
            XCTAssertEqual(loginResponse.user, .init(name: "Ida"))

            // test access token
            let accessTokenPayload: UserJWTPayload = try app.jwt.signers
                .require(kid: UserAccessKeychainConfig.jwkIdentifier)
                .verify(loginResponse.accessToken)
            XCTAssertEqual(accessTokenPayload.sub, "userID")
            XCTAssertEqual(accessTokenPayload.exp.value.timeIntervalSince1970, 300)

            // test refresh token
            let refreshTokenPayload: UserJWTPayload = try app.jwt.signers
                .require(kid: UserRefreshKeychainConfig.jwkIdentifier)
                .verify(loginResponse.refreshToken)
            XCTAssertEqual(refreshTokenPayload.sub, "userID")
            XCTAssertEqual(refreshTokenPayload.exp.value.timeIntervalSince1970, 600)
        }
    }

    func test_register() throws {
        try app.test(.POST, "register", beforeRequest: { request in
            try request.content.encode(["name": "Ida", "password": "secret"], as: .json)
        }) { response in
            XCTAssertEqual(response.status, .ok)

            // test user response
            let loginResponse = try response.content.decode(TestAuthenticationResponse.self)
            XCTAssertEqual(loginResponse.user, .init(name: "Ida"))

            // test access token
            let accessTokenPayload: UserJWTPayload = try app.jwt.signers
                .require(kid: UserAccessKeychainConfig.jwkIdentifier)
                .verify(loginResponse.accessToken)
            XCTAssertEqual(accessTokenPayload.sub, "userID")
            XCTAssertEqual(accessTokenPayload.exp.value.timeIntervalSince1970, 300)

            // test refresh token
            let refreshTokenPayload: UserJWTPayload = try app.jwt.signers
                .require(kid: UserRefreshKeychainConfig.jwkIdentifier)
                .verify(loginResponse.refreshToken)
            XCTAssertEqual(refreshTokenPayload.sub, "userID")
            XCTAssertEqual(refreshTokenPayload.exp.value.timeIntervalSince1970, 600)
        }

        // test user is persisted
        let user = try XCTUnwrap(app.users.testUser)
        XCTAssertEqual(user.name, "Ida")
        XCTAssertNoThrow(try app.password.verify("secret", created: user.hashedPassword))
    }

    func test_forgotPassword_ignoresUserNotFound() throws {
        try app.test(.POST, "password/forgot", beforeRequest: { request in
            try request.content.encode(["name": "Ida"], as: .json)
        }) { response in
            XCTAssertEqual(response.status, .accepted)
        }
    }

    func test_forgotPassword() throws {
        app.users.testUser = .test
        try app.test(.POST, "password/forgot", beforeRequest: { request in
            try request.content.encode(["name": "Ida"], as: .json)
        }) { response in
            XCTAssertEqual(response.status, .accepted)
        }

        XCTAssertEqual(app.mail.capturedUser?.name, "Ida")
        XCTAssertEqual(app.mail.capturedConfig?.expirationTimeInterval, 400)

        // test reset token
        let accessTokenPayload: UserJWTPayload = try app.jwt.signers
            .require(kid: UserResetKeychainConfig.jwkIdentifier)
            .verify(app.mail.capturedToken ?? "")
        XCTAssertEqual(accessTokenPayload.sub, "userID")
        XCTAssertEqual(accessTokenPayload.exp.value.timeIntervalSince1970, 400)
    }

    func test_resetPassword_requiresAuthentication() throws {
        try app.test(.POST, "password/reset") { response in
            XCTAssertEqual(response.status, .unauthorized)
        }
    }

    func test_resetPassword() throws {
        app.users.testUser = .test
        try app.test(.POST, "password/reset", beforeRequest: { request in
            let token = try self.app.jwt.signers
                .sign(
                    UserJWTPayload(expirationDate: Date(), user: .test),
                    kid: UserResetKeychainConfig.jwkIdentifier
                )
            request.headers.bearerAuthorization = .init(token: token)
            try request.content.encode(["password": "secret2"], as: .json)
        }) { response in
            XCTAssertTrue(try app.password.verify(
                "secret2",
                created: app.users.testUser?.hashedPassword ?? ""
            ))
            XCTAssertEqual(response.status, .ok)
        }
    }
}
