import JWT
import Vapor

final class JWTKeychainMiddleware<P: JWTKeychainPayload>: Middleware {
    let signer: JWTSigner

    init(signer: JWTSigner) {
        self.signer = signer
    }

    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let cache = try request.make(PayloadCache<P>.self)

        if cache.payload == nil {
            let token = try request.bearerToken()

            let jwt = try JWT<P>(from: token, verifiedUsing: signer)
            let payload = jwt.payload
            try payload.verify()

            cache.payload = payload
        }

        return try next.respond(to: request)
    }
}
