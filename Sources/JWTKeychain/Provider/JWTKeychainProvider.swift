/*
import Authentication
import Service
import Sugar

public final class JWTKeychainProvider<U: JWTKeychainUserType> {
    private let configFactory: (Container) throws -> JWTKeychainConfig<U>

    public init(configFactory: @escaping (Container) throws -> JWTKeychainConfig<U>) {
        self.configFactory = configFactory
    }
}

// MARK: - Provider
extension JWTKeychainProvider: Provider {
    public func register(_ services: inout Services) throws {
        services.register(factory: configFactory)

        services.register { container -> JWTKeychainMiddlewares<U> in
            let config: JWTKeychainConfig<U> = try container.make()
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

            return .init(
                accessMiddlewares: accessMiddlewares,
                refreshMiddlewares: refreshMiddlewares
            )
        }

        try services.register(AuthenticationProvider())
    }

    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }
}
*/
