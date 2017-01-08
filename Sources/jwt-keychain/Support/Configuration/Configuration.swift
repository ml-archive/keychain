import Foundation
import Vapor
import HTTP
import VaporJWT
import Auth

/// Sets the protocol of what is expected on the config file
public protocol ConfigurationType {
    
    static var secondsToExpire: Double? { get }
    
    static var signatureKey: String? { get }
    
    init(drop: Droplet) throws
}

public struct Configuration: ConfigurationType {
    
    /// Enumeration of fields that should be present on the config
    public enum Field: String {
        case secondsToExpire    = "jwt.secondsToExpire"
        case signatureKey       = "jwt.signatureKey"
        
        var path: [String] {
            return rawValue.components(separatedBy: ".")
        }
        
        var error: Abort {
            return .custom(status: .internalServerError,
                           message: "JWT error - \(rawValue) config is missing.")
        }
    }
    
    /// Seconds the JWT has to expire (in the future)
    public static var secondsToExpire: Double? = nil
    
    /// Key used to sign the JWT
    public static var signatureKey: String? = nil
    
    public init(drop: Droplet) throws {
        Configuration.secondsToExpire = try Configuration.extract(field: .secondsToExpire , drop: drop)
        Configuration.signatureKey    = try Configuration.extract(field: .signatureKey, drop: drop)
    }
    
    /// Extracts the given field from the JSON config
    /// as a String
    ///
    /// - Parameters:
    ///   - field: field to be extracted
    ///   - drop: droplet instance
    /// - Returns: string with the value
    /// - Throws: if field not found
    private static func extract(field: Field , drop: Droplet) throws -> String {
        guard let string = drop.config[field.path]?.string else {
            throw field.error
        }
        
        return string
    }
    
    
    /// Extracts the given field from the JSON config
    /// as an Double
    ///
    /// - Parameters:
    ///   - field: field to be extracted
    ///   - drop: droplet instance
    /// - Returns: double with the value
    /// - Throws: if field not found
    private static func extract(field: Field , drop: Droplet) throws -> Double {
        guard let double = drop.config[field.path]?.double else {
            throw field.error
        }
        
        return double
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
