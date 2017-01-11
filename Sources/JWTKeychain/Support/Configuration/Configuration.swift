import Foundation
import Vapor
import HTTP
import VaporJWT
import Auth

/// Sets the protocol of what is expected on the config file
public protocol ConfigurationType {
    
    static var secondsToExpire: Double? { get }
    
    static var signatureKey: String? { get }
    
    static func boot(secondsToExpire: Double, signatureKey: String) throws
}

public struct Configuration: ConfigurationType {
    
    /// Seconds the JWT has to expire (in the future)
    public static var secondsToExpire: Double? = nil
    
    /// Key used to sign the JWT
    public static var signatureKey: String? = nil
    
    // Register configs
    public static func boot(secondsToExpire: Double, signatureKey: String) throws {
        Configuration.secondsToExpire = secondsToExpire
        Configuration.signatureKey    = signatureKey
    }
    
    
    /// Gets token signature key
    ///
    /// - Returns: signature key
    /// - Throws: if cannot retrieve signature key
    public static func getTokenSignatureKey() throws -> Bytes {
        
        return Array(Configuration.signatureKey!.utf8)
        
    }
    
    /// Generates the expiration date based on the
    /// configured seconds to expire
    ///
    /// - Returns: token expiration date
    /// - Throws: on unable to create the date
    public static func generateExpirationDate() throws -> Date {
        
        return Date() + Configuration.secondsToExpire!
        
    }
    
    
    /// Validates a given token
    ///
    /// - Parameter token: string with the token
    /// - Returns: true if token is valid, else false
    /// - Throws: if unable to create JWT instance
    public static func validateToken(token: String) throws -> Bool {
        
        do {
            
            // Validate our current access token
            let receivedJWT = try JWT(token: token)
            
            // Verify signature
            if try receivedJWT.verifySignatureWith(HS256(key: Configuration.getTokenSignatureKey())) {
                
                
                // If we have expiration set on config, verify it
                if Configuration.secondsToExpire! > 0 {
                    
                    return receivedJWT.verifyClaims([ExpirationTimeClaim()])
                    
                }
                
                // No claims to verify so return true
                return true
                
            }
            
        } catch {
            
            throw AuthError.invalidBearerAuthorization
            
        }
        
        return false
    }
    
}
