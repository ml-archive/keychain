import Vapor
import HTTP
import Auth
import Turnstile


// MARK: -  User and token functionality
extension Request {
    
    // Base URL returns the hostname, scheme, and port in a URL string form.
    public var baseURL: String {
        return uri.scheme + "://" + uri.host + (uri.port == nil ? "" : ":\(uri.port!)")
    }
    
    // Exposes the Turnstile subject, as Vapor has a facade on it.
    public var subject: Subject {
        return storage["subject"] as! Subject
    }
    
    /// A helper method to retrieve the authenticated user
    ///
    /// - Returns: Authenticated user
    /// - Throws: UnsupportedCredentialsError
    public func user<T: UserType>() throws -> T {
        
        // Try to retrieve authenticated user
        guard let user = try auth.user() as? T else {
            throw UnsupportedCredentialsError()
        }
        return user
    }
    
    
    /// Retrieves the access token from the current
    /// request authorization header
    ///
    /// - Returns: AccessToken
    /// - Throws: No authorization header or invalid bearer authorization
    public func getAuthorizationBearerToken() throws -> AccessToken {
        
        // Try to get the authorization header
        guard let authHeader = self.auth.header else {
            throw Auth.AuthError.noAuthorizationHeader
        }
        
        // Try to retrieve the bearer token
        guard let bearer = authHeader.bearer else {
            throw Auth.AuthError.invalidBearerAuthorization
        }
        
        return bearer
    }
}
