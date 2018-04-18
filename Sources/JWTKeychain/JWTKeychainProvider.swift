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
    public let middleware: Middleware

    private let config: JWTKeychainConfig

    public init(config: JWTKeychainConfig) {
        self.config = config
        middleware = JWTKeychainMiddleware<P>(signer: config.accessTokenSigner)
    }
}

// MARK: - Provider
extension JWTCustomPayloadKeychainProvider: Provider {
    public func register(_ services: inout Services) throws {
        services.register(config)
        services.register { _ in PayloadCache<P>() }
        services.register { _ in UserCache<U>() }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let router = try container.make(Router.self)

        let users = router.grouped("users")
        users.post { request -> Future<UserWithTokens<U>> in
            try U.register(on: request).map { UserWithTokens(user: $0) }
        }
        users.post("login") { request -> Future<UserWithTokens<U>> in
            try U.logIn(on: request).map { UserWithTokens(user: $0) }
        }

        let secured = users.grouped(middleware)

        secured.get("me") { request -> Future<U> in
            try request.user()
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
