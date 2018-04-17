import JWT
import Vapor
import Service

enum JWTKeychainError: Error {
    case unauthorized
}

extension JWTKeychainError: AbortError {
    var identifier: String {
        return "1"
    }

    var reason: String {
        return "Unauthorized"
    }

    var status: HTTPResponseStatus {
        return .unauthorized
    }
}

struct Payload: JWTPayload {
    let exp: ExpirationClaim
    let sub: SubjectClaim

    func verify() throws {
        try exp.verify()
    }
}

extension JWTSigner: Service {}

public final class JWTKeychainProvider<U: Content>: Provider {
    private let userCacheFactory: () -> UserCache<U>

    public init(loadUser: @escaping (String) throws -> U) {
        userCacheFactory = { UserCache<U>(loadUser: loadUser) }
    }

    public func register(_ services: inout Services) throws {
        // TODO: load key from config object
        let signer = JWTSigner.hs256(key: "secret".convertToData())
        services.register(signer)
        services.register { _ in self.userCacheFactory() }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let router = try container.make(Router.self)

        let middleware = JWTKeychainMiddleware<U>()

        let users = router
            .grouped(middleware)
            .grouped("users")

        users.get("me") { req -> U in
            return try req.user()
        }

        return .done(on: container)
    }
}

final class UserCache<U>: Service {
    private let loadUser: (String) throws -> U

    init(loadUser: @escaping (String) throws -> U) {
        self.loadUser = loadUser
    }

    var userId: String? = nil

    private var cachedUser: U?
    func user() throws -> U {
        if let loadedUser = cachedUser {
            return loadedUser
        } else if let userId = userId {
            let user = try loadUser(userId)
            cachedUser = user
            return user
        } else {
            throw JWTKeychainError.unauthorized
        }
    }
}

extension Request {
    public func verifyUserId() throws -> String {
        guard
            let authHeader = http.headers[.authorization].first,
            authHeader.starts(with: "Bearer ")
        else {
            throw JWTKeychainError.unauthorized
        }

        let token = String(authHeader[authHeader.index(authHeader.startIndex, offsetBy: 7)...])

        let signer = try make(JWTSigner.self)
        let jwt = try JWT<Payload>(from: token, verifiedUsing: signer)
        let payload = jwt.payload
        try payload.verify()

        return payload.sub.value
    }

    public func user<U>(userType: U.Type = U.self) throws -> U {
        let userService = try make(UserCache<U>.self)
        return try userService.user()
    }
}

final class JWTKeychainMiddleware<U>: Middleware {
    init() {}

    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let userCache = try request.make(UserCache<U>.self)
        if userCache.userId == nil {
            userCache.userId = try request.verifyUserId()
        }
        return try next.respond(to: request)
    }
}
