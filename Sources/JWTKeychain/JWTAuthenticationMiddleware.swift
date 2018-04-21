import Authentication
import JWT
import Vapor

final class JWTAuthenticationMiddleware<A: JWTAuthenticatable>: Middleware {
    let signer: JWTSigner

    public init(signer: JWTSigner, _ type: A.Type = A.self) {
        self.signer = signer
    }

    func respond(
        to req: Request,
        chainingTo next: Responder
    ) throws -> EventLoopFuture<Response> {
        if try req.isAuthenticated(A.self) {
            return try next.respond(to: req)
        }

        guard let bearer = req.http.headers.bearerAuthorization else {
            throw JWTKeychainError.invalidCredentials
        }

        let jwt = try JWT<A.JWTPayload>(from: bearer.token, verifiedUsing: signer)
        let payload = jwt.payload
        try payload.verify()

        return try A.authenticate(
            using: payload,
            on: req
        ).flatMap(to: Response.self) { a in
            guard let a = a else {
                throw Abort(.unauthorized, reason: "Invalid credentials")
            }

            // set authed on request
            try req.authenticate(a)
            return try next.respond(to: req)
        }
    }
}
