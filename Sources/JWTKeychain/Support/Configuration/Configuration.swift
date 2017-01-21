import Foundation
import Vapor
import HTTP
import VaporJWT
import Auth

/// Sets the protocol of what is expected on the config file
public protocol ConfigurationType {

    func validateToken(token: String) throws -> Bool
    func generateToken(userId: Node, extraClaims: Claim...) throws -> String
}

public struct Configuration: ConfigurationType {

    /// Seconds the JWT has to expire (in the future)
    private var secondsToExpire: Double

    /// Key used to sign the JWT
    private var signatureKey: String

    /// Key used to check the signing the JWT
    private var publicKey: String? = nil

    /// Which signer will be used while signing the JWT
    private var signer: String

    /// The path to the reset password email
    private var resetPasswordEmail: String

    public enum Error: Swift.Error {
        case noJWTConfig
        case missingConfig(String)
    }

    public init(drop: Droplet) throws {
        try self.init(config: drop.config)
    }

    public init(config: Config) throws {

        guard let jwtConfig = config["jwt"]?.object else {
            throw Error.noJWTConfig
        }

        guard let signer: String = jwtConfig["signer"]?.string else {
            throw Error.missingConfig("signer")
        }

        guard let secondsToExpire = jwtConfig["secondsToExpire"]?.double else {
            throw Error.missingConfig("secondsToExpire")
        }

        guard let signatureKey = jwtConfig["signatureKey"]?.string else {
            throw Error.missingConfig("signatureKey")
        }

        guard let resetPasswordEmail = jwtConfig["resetPasswordEmail"]?.string else {
            throw Error.missingConfig("resetPasswordEmail")
        }

        let publicKey: String? = jwtConfig["publicKey"]?.string

        if publicKey == nil {
            //The ECDSA and RSA (ES*/RS*) signers take a private key for signing and needs a matching public key for verifying.
            if signer.hasPrefix("ES") || signer.hasPrefix("RS"){
                throw Error.missingConfig("publicKey")
            }
        }

        self.init(
            signer: signer,
            signatureKey: signatureKey,
            publicKey: publicKey,
            secondsToExpire: secondsToExpire,
            resetPasswordEmail: resetPasswordEmail
        )

    }

    public init(signer: String, signatureKey: String, publicKey: String?, secondsToExpire: Double, resetPasswordEmail: String){
        self.signer = signer
        self.signatureKey = signatureKey
        self.publicKey = publicKey
        self.secondsToExpire = secondsToExpire
        self.resetPasswordEmail = resetPasswordEmail
    }

    /// The Bytes representation of the signatureKey
    var signatureKeyBytes : Bytes {
        return Array(self.signatureKey.utf8)
    }

    /// The Bytes representation of the publicKey (may be nil)
    var publicKeyBytes: Bytes? {
        if let publicKey = publicKey {
            return Array(publicKey.utf8)
        } else {
            return nil
        }
    }

    /// Generates the expiration date based on the
    /// configured seconds to expire
    ///
    /// - Returns: token expiration date
    /// - Throws: on unable to create the date
    public func generateExpirationDate() -> Date {
        return Date() + self.secondsToExpire

    }

    private func getSigner(key: Bytes) -> Signer {

        switch self.signer {

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
    public func validateToken(token: String) throws -> Bool {

        do {

            // Validate our current access token
            let receivedJWT = try JWT(token: token)

            var key: Bytes = self.signatureKeyBytes

            if let publicKeyBytes = self.publicKeyBytes {
                key = publicKeyBytes
            }

            // Verify signature
            let signer: Signer = self.getSigner(key: key)
            if try receivedJWT.verifySignatureWith(signer) {


                // If we have expiration set on config, verify it
                if self.secondsToExpire > 0 {

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

    /// Generates a token for the user
    /// - Parameter: userId is used to create a SubjectClaim
    /// - Parameter: extraClaims are optional customized claims
    /// - Returns: string with valid JWT token
    public func generateToken(userId: Node, extraClaims: Claim...) throws -> String {
         // Unwrap id
         guard let id = userId.string else {
            throw Abort.custom(status: .internalServerError, message: "JWTKeyChain.Configuration - Passed userId could not be casted to string, maybe its nil")
        }
        
        // Prepare payload Node
        var payload: Node

        // Prepare contents for payload
        var contents: [Claim] = []

        let subClaim = SubjectClaim(id)

        contents.append(subClaim)

        for claim in extraClaims {
            contents.append(claim)
        }

        // Prepare expiration claim if needed
        if self.secondsToExpire > 0 {
            
            contents.append(ExpirationTimeClaim(self.generateExpirationDate()))
            
        }
        
        payload = Node(contents)
        
        // Generate our Token
        let jwt = try JWT(
            payload: payload,
            signer: self.getSigner(key: self.signatureKeyBytes)
        )
        
        // Return the token string
        return try jwt.createToken()
        
    }
    
}
