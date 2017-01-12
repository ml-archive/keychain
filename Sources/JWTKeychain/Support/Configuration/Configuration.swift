import Foundation
import Vapor
import HTTP
import VaporJWT
import Auth

/// Sets the protocol of what is expected on the config file
public protocol ConfigurationType {
    
     var secondsToExpire: Double? { get }

     var signatureKey: String { get }

     var publicKey: String? { get }

     var signer: String { get }

    static func boot(signer: String, signatureKey: String, publicKey: String?, secondsToExpire: Double) throws
}

public struct Configuration: ConfigurationType {
    
    public static var instance: Configuration?;
    
    /// Seconds the JWT has to expire (in the future)
    public var secondsToExpire: Double? = nil
    
    /// Key used to sign the JWT
    public var signatureKey: String
    
    /// Key used to check the signing the JWT
    public var publicKey: String? = nil
    
    /// Which signer will be used while signing the JWT
    public var signer: String

    private init(signer: String, signatureKey: String, publicKey: String?, secondsToExpire: Double){
        self.signer = signer
        self.signatureKey = signatureKey
        self.publicKey = publicKey
        self.secondsToExpire = secondsToExpire}
    // Register configs
    public static func boot(signer: String, signatureKey: String, publicKey: String?, secondsToExpire: Double) throws {
        Configuration.instance = Configuration(signer: signer, signatureKey: signatureKey, publicKey: publicKey, secondsToExpire: secondsToExpire)
    }
    
    
    /// Gets token signature key
    ///
    /// - Returns: signature key
    public static func getTokenSignatureKey() -> Bytes {
        
        return Array(Configuration.instance!.signatureKey.utf8)
        
    }
    
    /// Gets token public key
    ///
    /// - Returns: public key
    /// - Throws: if cannot retrieve signature key
    public static func getTokenPublicKey() throws -> Bytes {
        return Array(Configuration.instance!.publicKey!.utf8)
        
    }
    
    /// Generates the expiration date based on the
    /// configured seconds to expire
    ///
    /// - Returns: token expiration date
    /// - Throws: on unable to create the date
    public static func generateExpirationDate() throws -> Date {
        
        return Date() + Configuration.instance!.secondsToExpire!
        
    }
    
    public static func getSigner(key: Bytes) -> Signer {
        switch Configuration.instance!.signer {
        case "HS384":
            return HS384(key: key)
        case "HS512":
            return HS512(key: key)
        case "ES256":
            return ES256(key: key)
        case "ES384":
            return ES384(key: key)
        case "ES512":
            return ES512(key: key)
        case "RS256":
            return ES256(key: key)
        case "RS384":
            return ES384(key: key)
        case "RS512":
            return ES512(key: key)
        default:
            return HS256(key: key)
            
        }
        
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
            
            var key: Bytes = Configuration.getTokenSignatureKey()
            
            if(Configuration.instance!.publicKey != nil){
                
                key = try Configuration.getTokenPublicKey()
            }
            
            // Verify signature
            let signer: Signer = Configuration.getSigner(key: key)
            if try receivedJWT.verifySignatureWith(signer) {
                
                
                // If we have expiration set on config, verify it
                if Configuration.instance!.secondsToExpire! > 0 {
                    
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
