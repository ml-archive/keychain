import JWT
import Vapor
import Service

enum JWTKeychainError: Error {
    case unauthorized
}

struct Payload: JWTPayload {
    let exp: ExpirationClaim
    let sub: SubjectClaim

    func verify() throws {
        try exp.verify()
    }
}

public final class JWTKeychainProvider: Provider {
    private let middleware: JWTKeychainMiddleware

    public init() {
        let signer = JWTSigner.hs256(key: "secret".convertToData())
        middleware = JWTKeychainMiddleware(signer: signer)
    }

    public func register(_ services: inout Services) throws {
        services.register { _ in UserService() }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let router = try container.make(Router.self)

        let users = router
            .grouped(middleware)
            .grouped("users")

        users.get("me") { req -> String in
            return try req.make(UserService.self).user ?? "unauthorized"
        }

        return .done(on: container)
    }
}

final class UserService: Service {
    var user: String?
}

final class JWTKeychainMiddleware: Middleware {
    let signer: JWTSigner

    init(signer: JWTSigner) {
        self.signer = signer
    }

    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard
            let authHeader = request.http.headers[.authorization].first,
            authHeader.starts(with: "Bearer ")
        else {
            throw JWTKeychainError.unauthorized
        }

        let token = String(authHeader[authHeader.index(authHeader.startIndex, offsetBy: 7)...])

        let jwt = try JWT<Payload>.init(from: token, verifiedUsing: self.signer)
        let payload = jwt.payload
        try payload.verify()

        let userService = try  request.make(UserService.self)
        userService.user = payload.sub.value

        return try next.respond(to: request)
    }
}
