import Authentication
import Fluent
import JWT
import Service
import Sugar
import Vapor

public struct JWTKeychainMiddlewares {
    public let accessMiddlewares: [Middleware]
    public let refreshMiddlewares: [Middleware]?
}

public final class JWTKeychainProvider<U: JWTCustomPayloadKeychainUserType> {
    public let middlewares: JWTKeychainMiddlewares
    public let config: JWTKeychainConfig

    public init(config: JWTKeychainConfig) {
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
    }

    public func didBoot(_ container: Container) throws -> Future<Void> {
        if config.shouldRegisterRoutes {
            try registerRoutes(on: container.make())
        }
        return .done(on: container)
    }
}

// MARK: - Private

// MARK: Routes
extension JWTKeychainProvider {
    public func logIn(req: Request) throws -> Future<UserResponse<U>> {
        return try U
            .logIn(on: req)
            .flatMap(to: UserResponse<U>.self) { user in
                try self.makeUserResponse(for: user, withOptions: .all, on: req)
            }
    }

    public func me(req: Request) throws -> Future<U.Public> {
        return try req.requireAuthenticated(U.self).convertToPublic(on: req)
    }

    public func register(req: Request) throws -> Future<UserResponse<U>> {
        return try U
            .register(on: req)
            .flatMap(to: UserResponse<U>.self) { user in
                try self.makeUserResponse(for: user, withOptions: .all, on: req)
            }
    }

    public func token(req: Request) throws -> Future<UserResponse<U>> {
        return try self.makeUserResponse(
            for: req.requireAuthenticated(U.self),
            withOptions: .accessToken,
            on: req
        )
    }

    public func update(req: Request) throws -> Future<U.Public> {
        return try U.update(on: req)
            .flatMap { try $0.convertToPublic(on: req) }
    }
}

// MARK: Helper
private extension JWTKeychainProvider {
    func registerRoutes(on router: Router) {
        let endpoints = config.endpoints

        if let registerPath = endpoints.register {
            router.post(registerPath, use: register)
        }

        if let loginPath = endpoints.login {
            router.post(loginPath, use: logIn)
        }

        let access = router.grouped(middlewares.accessMiddlewares)

        if let mePath = endpoints.me {
            access.get(mePath, use: me)
        }

        if let updatePath = endpoints.update {
            access.patch(updatePath, use: update)
        }

        if
            let refreshMiddlewares = middlewares.refreshMiddlewares,
            let tokenPath = endpoints.token
        {
            router.grouped(refreshMiddlewares).post(tokenPath, use: token)
        }
    }
}