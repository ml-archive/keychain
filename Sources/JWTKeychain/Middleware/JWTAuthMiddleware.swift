import Vapor
import HTTP
import Turnstile
import Auth
import VaporJWT

/// Middleware to extract and authorize a user via 
/// Authorization Bearer Token + JWT
class JWTAuthMiddleware: Middleware {
    
    /// Initiates the middleware logic
    ///
    /// - Parameters:
    ///   - request: current request
    ///   - next: next middleware to execute in the chain
    /// - Returns: response from the next middleware in the chain
    /// - Throws: Unauthorized if auth fails or bad request if authorization is not set
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        // Authorization: Bearer Token
        do{
            
            let bearer = try request.getAuthorizationBearerToken()
            
            // Verify the token
            if try Configuration.validateToken(token: bearer.string) {
                
                try? request.auth.login(bearer, persist: false)
                
            } else {
                throw Abort.custom(
                    status: .unauthorized,
                    message: "Please reauthenticate with the server."
                )
            }
            
        } catch AuthError.noAuthorizationHeader {
            
            throw Abort.custom(
                status: .badRequest,
                message: "Authorization header not set."
            )
            
        } catch AuthError.invalidBearerAuthorization  {
            
            throw Abort.custom(
                status: .unauthorized,
                message: "Invalid bearer token"
            )
            
        }
        
        return try next.respond(to: request)
    }
}
