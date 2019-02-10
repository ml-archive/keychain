import Authentication
import Service
import Sugar

public final class JWTKeychainProvider<U: JWTKeychainUserType> {
    public let middlewares: JWTKeychainMiddlewares<U>
    public let config: JWTKeychainConfig<U>

    public init(config: JWTKeychainConfig<U>) {
        self.config = config

        var accessMiddlewares: [Middleware] = [
            JWTAuthenticationMiddleware<U>(
                signer: config.accessTokenSigner.signer
            )
        ]

        var refreshMiddlewares: [Middleware]? = config.refreshTokenSigner.map {
            [JWTAuthenticationMiddleware<U>(signer: $0.signer)]
        }

        if config.forceAuthentication {
            let guardMiddleware = U.guardAuthMiddleware()
            accessMiddlewares.append(guardMiddleware)
            refreshMiddlewares?.append(guardMiddleware)
        }

        self.middlewares = .init(
            accessMiddlewares: accessMiddlewares,
            refreshMiddlewares: refreshMiddlewares
        )
    }
}

// MARK: - Provider
extension JWTKeychainProvider: Provider {
    public func register(_ services: inout Services) throws {
        services.register(config)
        try services.register(AuthenticationProvider())
        services.register(self.middlewares)
    }

    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }
}
