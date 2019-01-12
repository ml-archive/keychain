import Authentication
import Fluent
import JWT
import Service
import Sugar
import Vapor

public struct JWTKeychainMiddlewares: Service {
    public let accessMiddlewares: [Middleware]
    public let refreshMiddlewares: [Middleware]?
}

public final class JWTKeychainProvider<U: JWTCustomPayloadKeychainUserType> {
    public let middlewares: JWTKeychainMiddlewares
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

// MARK: Routes

public extension Router {
    func useJWTKeychainRoutes<U: JWTCustomPayloadKeychainUserType>(
        _ type: U.Type,
        on container: Container
    ) throws {
        let config: JWTKeychainConfig<U> = try container.make()
        let middlewares: JWTKeychainMiddlewares = try container.make()
        let access = self.grouped(middlewares.accessMiddlewares)

        if let registerPath = config.endpoints.register {
            self.post(registerPath, use: config.controller.register)
        }

        if let loginPath = config.endpoints.login {
            self.post(loginPath, use: config.controller.logIn)
        }

        if let mePath = config.endpoints.me {
            access.get(mePath, use: config.controller.me)
        }

        if let updatePath = config.endpoints.update {
            access.patch(updatePath, use: config.controller.update)
        }

        if
            let refreshMiddlewares = middlewares.refreshMiddlewares,
            let tokenPath = config.endpoints.token
        {
            self.grouped(refreshMiddlewares).post(tokenPath, use: config.controller.token)
        }
    }
}
