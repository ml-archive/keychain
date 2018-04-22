import Authentication
import Fluent
import JWT
import Vapor
import Service

public typealias UserLoader<U> = (Request) throws -> Future<U>

public final class JWTKeychainProvider<U: JWTCustomPayloadKeychainUser> {
    public let accessMiddleware: Middleware
    public let refreshMiddleware: Middleware?

    public let config: JWTKeychainConfig

    public init(config: JWTKeychainConfig) {
        self.config = config

        accessMiddleware = JWTAuthenticationMiddleware<U>(signer: config.accessTokenSigner.signer)
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
        try registerRoutes(on: container.make())
        return .done(on: container)
    }
}

// MARK: - Private

// MARK: Routes
private extension JWTKeychainProvider {
    func logIn(req: Request) throws -> Future<UserResponse<U>> {
        return try U
            .logIn(on: req)
            .flatMap(to: UserResponse<U>.self) { user in
                self.makeUserResponse(for: user, withOptions: .all, on: req)
            }
    }

    func me(req: Request) throws -> U.Public {
        return try req.requireAuthenticated(U.self).convertToPublic()
    }

    func register(req: Request) throws -> Future<UserResponse<U>> {
        return try U
            .register(on: req)
            .flatMap(to: UserResponse<U>.self) { user in
                self.makeUserResponse(for: user, withOptions: .all, on: req)
            }
    }

    func token(req: Request) throws -> Future<UserResponse<U>> {
        return try self.makeUserResponse(
            for: req.requireAuthenticated(),
            withOptions: .accessToken,
            on: req
        )
    }

    func update(req: Request) throws -> Future<U.Public> {
        return try req
            .content
            .decode(U.Update.self)
            .flatMap(to: U.self) {
                try req
                    .requireAuthenticated(U.self)
                    .update(using: $0)
                    .save(on: req)
            }
            .map { $0.convertToPublic() }
    }
}

// MARK: Helper
private extension JWTKeychainProvider {
    func registerRoutes(on router: Router) {
        let users = router.grouped("users")
        users.post(use: register)
        users.post("login", use: logIn)

        let access = users.grouped(accessMiddleware)

        access.get("me", use: me)
        access.patch("me", use: update)

        if let refreshMiddleware = refreshMiddleware {
            users.grouped(refreshMiddleware).post("token", use: token)
        }
    }
}
