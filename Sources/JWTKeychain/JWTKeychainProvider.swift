import Fluent
import JWT
import Vapor
import Service

extension JWTSigner: Service {}

public typealias UserLoader<U> = (Request) throws -> Future<U>

public typealias JWTKeychainProvider<U: Content> = JWTCustomPayloadKeychainProvider<U, Payload>

public final class JWTCustomPayloadKeychainProvider<U: Content, P: JWTKeychainPayload>: Provider {
    private let config: JWTKeychainConfig
    private let userCacheFactory: () -> UserCache<U>

    public let middleware: Middleware
    public let signer: JWTSigner

    public init(config: JWTKeychainConfig, loadUser: @escaping UserLoader<U>) {
        self.config = config
        signer = config.makeSigner()
        middleware = JWTKeychainMiddleware<P>(signer: signer)
        userCacheFactory = { UserCache<U>(loadUser: loadUser) }
    }

    public func register(_ services: inout Services) throws {
        services.register(config.makeSigner())
        services.register { _ in self.userCacheFactory() }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let router = try container.make(Router.self)

        let users = router
            .grouped(middleware)
            .grouped("users")

        users.get("me") { request -> Future<U> in
            try request.user()
        }

        return .done(on: container)
    }
}

extension JWTCustomPayloadKeychainProvider where U: Model, U.Database: QuerySupporting {
    convenience init(config: JWTKeychainConfig, transformId: @escaping (String) -> U.ID?) {
        self.init(config: config) { request in
            let payload: P = try request.payload()

            guard let id = transformId(payload.sub.value) else {
                throw JWTKeychainError.invalidIdentifier
            }

            return try U.find(id, on: request).map(to: U.self) {
                guard let user = $0 else {
                    throw JWTKeychainError.userNotFound
                }

                return user
            }
        }
    }
}

extension JWTCustomPayloadKeychainProvider where U: Model, U.Database: QuerySupporting, U.ID == Int {
    public convenience init(config: JWTKeychainConfig) {
        self.init(config: config, transformId: Int.init)
    }
}

extension JWTCustomPayloadKeychainProvider where U: Model, U.Database: QuerySupporting, U.ID == String {
    public convenience init(config: JWTKeychainConfig) {
        self.init(config: config, transformId: String.init)
    }
}

extension JWTCustomPayloadKeychainProvider where U: Model, U.Database: QuerySupporting, U.ID == UUID  {
    public convenience init(config: JWTKeychainConfig) {
        self.init(config: config, transformId: { UUID($0) })
    }
}
