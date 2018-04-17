import JWT
import Vapor
import Service

enum JWTKeychainError: Error {
    case unauthorized
    case userNotFound
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

public typealias UserLoader<U> = (Request, String) throws -> Future<U>

public final class JWTKeychainProvider<U: Content>: Provider {
    private let userCacheFactory: () -> UserCache<U>

    public init(loadUser: @escaping UserLoader<U>) {
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

        users.get("me") { (request: Request) -> Future<U> in

            try request.user().flatMap(to: U.self) { (u: U) in
                print(u)
                return try request.user()
            }
        }

        return .done(on: container)
    }
}

import Fluent
import Vapor

extension JWTKeychainProvider where U: Model, U.ID == Int, U.Database: QuerySupporting {
    public convenience init() {
        self.init { (request, id) -> Future<U> in
            try U.find(Int(id) ?? 0, on: request)
                .map(to: U.self) {
                    guard let user = $0 else {
                        throw JWTKeychainError.userNotFound
                    }
                    return user
            }
        }
    }
}

final class UserCache<U>: Service {
    private let loadUser: UserLoader<U>

    init(loadUser: @escaping UserLoader<U>) {
        self.loadUser = loadUser
    }

    var userId: String? = nil

    private var cachedUser: Future<U>?
    func user(on request: Request) throws -> Future<U> {
        if let cachedUser = cachedUser {
            return cachedUser
        } else if let userId = userId {
            let user = try loadUser(request, userId)
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

    public func user<U>(userType: U.Type = U.self) throws -> Future<U> {
        let userService = try make(UserCache<U>.self)
        return try userService.user(on: self)
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
