// TODO: use JWTProvider PayloadAuthenticationMiddleware

//import Vapor
//import HTTP
//import Authentication
//import JWT
//
///// Middleware to extract and authorize a user via
///// Authorization Bearer Token + JWT
//public class AuthMiddleware: Middleware {
//    private let configuration: ConfigurationType
//
//    /// Initializes JWTAuthMiddleware with a JWT configuration
//    ///
//    /// - Parameters:
//    /// configuration : the JWT configuration to be used to validate user tokens
//    public init(configuration: ConfigurationType) {
//        self.configuration = configuration
//    }
//
//    /// Initiates the middleware logic
//    ///
//    /// - Parameters:
//    ///   - request: current request
//    ///   - next: next middleware to execute in the chain
//    /// - Returns: response from the next middleware in the chain
//    /// - Throws: Unauthorized if auth fails or bad request if authorization is not set
//    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
//        // Authorization: Bearer Token
//        do {
//            let bearer = try request.getAuthorizationBearerToken()
//
//            // Verify the token
//            do {
//                try self.configuration.validateToken(token: bearer.string)
//                try? request.auth.login(bearer, persist: false)
//            } catch Configuration.Error.invalidClaims {
//                throw Abort(
//                    .unauthorized,
//                    metadata: "Please reauthenticate with the server."
//                )
//            }
//        } catch AuthenticationError.noAuthorizationHeader {
//            throw Abort(
//                .badRequest,
//                metadata: "Authorization header not set."
//            )
//        } catch AuthenticationError.invalidBearerAuthorization  {
//            throw Abort(
//                .unauthorized,
//                metadata: "Invalid bearer token"
//            )
//        }
//
//        return try next.respond(to: request)
//    }
//}
