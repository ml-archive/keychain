import Fluent
import JWT
import Vapor
import Service

extension JWTSigner: Service {}

public typealias UserLoader<U> = (Request) throws -> Future<U>

public typealias JWTKeychainProvider<U: JWTKeychainUser> =
    JWTCustomPayloadKeychainProvider<U, Payload>

public final class JWTCustomPayloadKeychainProvider
    <U: JWTKeychainUser, P: JWTKeychainPayload>
{
    public let middleware: Middleware
    public let signer: JWTSigner

    private let config: JWTKeychainConfig

    public init(config: JWTKeychainConfig) {
        self.config = config
        signer = config.makeSigner()
        middleware = JWTKeychainMiddleware<P>(signer: signer)
    }
}

// MARK: - Provider
extension JWTCustomPayloadKeychainProvider: Provider {
    public func register(_ services: inout Services) throws {
        services.register(config.makeSigner())
        services.register { _ in PayloadCache<P>() }
        services.register { _ in UserCache<U>() }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let router = try container.make(Router.self)

        let users = router
            .grouped(middleware)
            .grouped("users")

        users.get("me") { request -> Future<U> in
            try request.user()
        }

        users.post { request -> Future<UserWithTokens<U>> in
            try U.decode(from: request)
                .flatMap(to: U.self) { (user: U) in
                    try user.register(on: request)
                }.map(UserWithTokens.init)
        }

        return .done(on: container)
    }
}

struct UserWithTokens<U: Codable>: Content {
    let user: U
}
