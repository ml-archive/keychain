import Authentication
import Fluent
import JWT
import Service
import Sugar
import Vapor

public final class JWTKeychainProvider<U: JWTCustomPayloadKeychainUser> {
    public let accessMiddleware: Middleware
    public let refreshMiddleware: Middleware?

    public let config: JWTKeychainConfig

    public init(config: JWTKeychainConfig) {
        self.config = config

        accessMiddleware = JWTAuthenticationMiddleware<U>(
            signer: config.accessTokenSigner.signer
        )
        refreshMiddleware = config.refreshTokenSigner.map {
            JWTAuthenticationMiddleware<U>(signer: $0.signer)
        }
    }
}

// MARK: - Provider
extension JWTKeychainProvider: Provider {
    public func register(_ services: inout Services) throws {
        services.register(config)
        try services.register(AuthenticationProvider())
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
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

    public func me(req: Request) throws -> U.Public {
        return try req.requireAuthenticated(U.self).convertToPublic()
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
            .map { $0.convertToPublic() }
    }
}

// MARK: Helper
private extension JWTKeychainProvider {
    func registerRoutes(on router: Router) {
        let endpoints = config.endpoints

        router.post(endpoints.register, use: register)
        router.post(endpoints.login, use: logIn)

        let access = router.grouped([accessMiddleware, U.guardAuthMiddleware()])

        access.get(endpoints.me, use: me)
        access.patch(endpoints.update, use: update)

        if let refreshMiddleware = refreshMiddleware {
            router.grouped(refreshMiddleware).post(endpoints.token, use: token)
        }
    }
}
