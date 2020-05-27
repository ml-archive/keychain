@testable import JWTKeychain
import Vapor
import JWT
import XCTVapor


struct AppUser: Content, Equatable {
    let id = "userID"
}

struct LoginResponse: Content, Equatable {
    let user: AppUser
    let accessToken: String
}

struct AppJWTPayload: KeychainPayload {
    typealias User = AppUser

    let exp: ExpirationClaim
    let sub: SubjectClaim

    init(expirationDate: Date, user: AppUser) throws {
        self.exp = .init(value: expirationDate)
        self.sub = .init(value: user.id)
    }

    func findUser(request: Request) -> EventLoopFuture<AppUser> {
        request.eventLoop.future(AppUser())
    }

    func verify(using signer: JWTSigner) throws {
         try exp.verifyNotExpired()
    }
}

struct TestJWTAlgorithm: JWTAlgorithm {
    let name: String
    func sign<Plaintext: DataProtocol>(_ plaintext: Plaintext) -> [UInt8] {
        "signed by \(name): ".compactMap { $0.asciiValue } + plaintext.map { $0 }
    }

    func verify<Signature: DataProtocol, Plaintext: DataProtocol>(
        _ signature: Signature,
        signs plaintext: Plaintext
    ) -> Bool {
        signature.map { $0 } == ("signed by \(name): ".compactMap { $0.asciiValue } + plaintext)
    }
}

extension JWTError: Equatable {
    public static func == (lhs: JWTError, rhs: JWTError) -> Bool {
        lhs.description == rhs.description
    }
}

class JWTKeychainTests: XCTestCase {
    struct Config: KeychainConfig, Equatable {
        typealias JWTPayload = AppJWTPayload

        static var jwkIdentifier = JWKIdentifier(string: "")
        
        var expirationTimeInterval: TimeInterval
    }

    let config = Config(expirationTimeInterval: 300)
    var app: Application!

    override func setUp() {
        app = Application(.testing)
    }

    override func tearDown() {
        app.shutdown()
    }

    func testConfig() throws {
        app.keychain.configure(signer: JWTSigner(algorithm: TestJWTAlgorithm(name: Config.jwkIdentifier.string)), config: config)
        app.get("") { req -> String in
            XCTAssertEqual(req.keychain.config(for: Config.self), self.config)
            return ""
        }

        try app.test(.GET, "") {res in
            XCTAssertEqual(res.status, .ok)

        }
    }

    func testLogin() throws {
        app.keychain.configure(signer: JWTSigner(algorithm: TestJWTAlgorithm(name: Config.jwkIdentifier.string)), config: config)
        app.post( "login") { req -> LoginResponse in
            let accessToken = try self.app.keychain.config(for: Config.self).makeToken(for: .init(), on: req, currentDate: .init(timeIntervalSince1970: 0))
            return  LoginResponse(user: .init(), accessToken: accessToken)
        }

        try app.test(.POST, "login") { response in
            XCTAssertEqual(response.status, .ok)
            let loginResponse = try XCTUnwrap(response.content.decode(LoginResponse.self))
            XCTAssertEqual(loginResponse, LoginResponse(
                user: .init(),
                accessToken: "eyJhbGciOiIiLCJraWQiOiIifQ.eyJleHAiOjMwMCwic3ViIjoidXNlcklEIn0.c2lnbmVkIGJ5IDogZXlKaGJHY2lPaUlpTENKcmFXUWlPaUlpZlEuZXlKbGVIQWlPak13TUN3aWMzVmlJam9pZFhObGNrbEVJbjA"
            ))
        }
    }

    func testExpired() throws {
        app.keychain.configure(signer: JWTSigner(algorithm: TestJWTAlgorithm(name: Config.jwkIdentifier.string)), config: config)
        let expiredPayload = try AppJWTPayload(expirationDate: .init(timeIntervalSince1970: 0), user: AppUser())
        let notExpiredPayload = try AppJWTPayload(expirationDate: .init(timeIntervalSinceNow: 300), user: AppUser())
        let signer = try XCTUnwrap(app.jwt.signers.get(kid: Config.jwkIdentifier))

        XCTAssertThrowsError(try expiredPayload.verify(using: signer)) { error in
            XCTAssertEqual(error as! JWTError, JWTError.claimVerificationFailure(name: "exp", reason: "expired"))
        }
        XCTAssertNoThrow(try notExpiredPayload.verify(using: signer))
    }
}
