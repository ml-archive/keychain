import JWT
import Vapor

public protocol KeychainConfig {
    associatedtype JWTPayload: KeychainPayload
    static var jwkIdentifier: JWKIdentifier { get }
    var expirationTimeInterval: TimeInterval { get }
}

extension KeychainConfig where JWTPayload.User: Authenticatable {
    public static var authenticator: some JWTAuthenticator { Authenticator<Self>() }
}

extension KeychainConfig {
    public static func makeToken(
        for user: JWTPayload.User,
        on request: Request,
        currentDate: Date = Date()
    ) throws -> String {
        try request
            .keychain
            .config(for: Self.self)
            .makeToken(for: user, on: request, currentDate: currentDate)
    }

    public func makeToken(
        for user: JWTPayload.User,
        on request: Request,
        currentDate: Date = Date()
    ) throws -> String {
        try request.jwt.sign(
            JWTPayload(
                expirationDate: currentDate.addingTimeInterval(expirationTimeInterval),
                user: user
            ),
            kid: Self.jwkIdentifier
        )
    }
}

extension KeychainConfig where JWTPayload.User: Authenticatable {
    public static func makeToken(
        on request: Request,
        currentDate: Date = Date()
    ) throws -> String {
        try makeToken(for: request.auth.require(), on: request, currentDate: currentDate)
    }

    public func makeToken(
        on request: Request,
        currentDate: Date = Date()
    ) throws -> String {
        try makeToken(for: request.auth.require(), on: request, currentDate: currentDate)
    }
}

struct Authenticator<T: KeychainConfig>: JWTAuthenticator where T.JWTPayload.User: Authenticatable {
    func authenticate(
        jwt: T.JWTPayload,
        for request: Request
    ) -> EventLoopFuture<Void> {
        jwt.findUser(request: request).map(request.auth.login)
    }
}
