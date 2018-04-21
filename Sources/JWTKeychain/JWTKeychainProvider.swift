import Authentication
import Fluent
import JWT
import Vapor
import Service

public typealias UserLoader<U> = (Request) throws -> Future<U>

public typealias JWTKeychainProvider<U: JWTKeychainUser> =
    JWTCustomPayloadKeychainProvider<U, Payload>

public final class JWTCustomPayloadKeychainProvider
    <U: JWTKeychainUser, P: JWTKeychainPayload>
{
    // TODO: only expose through services instead?
    public let middleware: Middleware

    private let config: JWTKeychainConfig

    public init(config: JWTKeychainConfig) {
        self.config = config

        middleware = JWTAuthenticationMiddleware<U>(signer: config.accessTokenSigner)
    }
}

// MARK: - Provider
extension JWTCustomPayloadKeychainProvider: Provider {
    public func register(_ services: inout Services) throws {
        services.register(config)
        try services.register(AuthenticationProvider())
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let router = try container.make(Router.self)

        let users = router.grouped("users")
        users.post { req -> Future<UserWithTokens<U>> in
            try U.register(on: req).map { UserWithTokens(user: $0) }
        }
        users.post("login") { req -> Future<UserWithTokens<U>> in
            try U.logIn(on: req).map { UserWithTokens(user: $0) }
        }

        let secured = users.grouped(middleware)

        secured.get("me") { req -> U.Public in
            return try req.requireAuthenticated(U.self).publicRepresentation()
        }

        secured.patch("me") { req -> Future<U> in
            return try req
                .content
                .decode(U.Update.self)
                .flatMap(to: U.self) {
                    return try req
                        .requireAuthenticated(U.self)
                        .update(using: $0)
                        .save(on: req)
            }
        }

        return .done(on: container)
    }
}

struct UserWithTokens<U: Codable>: Content {
    let user: U
    let accessToken: String?
    let refreshToken: String?

    init(user: U, accessToken: String? = nil, refreshToken: String? = nil) {
        self.user = user
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
