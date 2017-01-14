import Foundation
import Vapor
import HTTP
import VaporJWT
import Auth

/// Sets the protocol of what is expected on the config file
public protocol ConfigurationType {

     var secondsToExpire: Double { get }

     var signatureKey: String { get }

     var publicKey: String? { get }

     var signer: String { get }

     func getTokenSignatureKey() -> Bytes
     func generateExpirationDate() -> Date
     func getSigner(key: Bytes) -> Signer
     func validateToken(token: String) throws -> Bool
     func generateToken(userId: Node) throws -> String
}

public struct Configuration: ConfigurationType {

    /// Seconds the JWT has to expire (in the future)
    public var secondsToExpire: Double

    /// Key used to sign the JWT
    public var signatureKey: String

    /// Key used to check the signing the JWT
    public var publicKey: String? = nil

    /// Which signer will be used while signing the JWT
    public var signer: String

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

        let publicKey: String? = jwtConfig["publicKey"]?.string

        if publicKey == nil {
            //The ECDSA and RSA (ES*/RS*) signers take a private key for signing and needs a matching public key for verifying.
            if signer.hasPrefix("ES") || signer.hasPrefix("RS"){
                throw Error.missingConfig("publicKey")
            }
        }

        self.init(signer: signer, signatureKey: signatureKey, publicKey: publicKey, secondsToExpire: secondsToExpire)

    }

    public init(signer: String, signatureKey: String, publicKey: String?, secondsToExpire: Double){
        self.signer = signer
        self.signatureKey = signatureKey
        self.publicKey = publicKey
        self.secondsToExpire = secondsToExpire
      }

    /// Gets token signature key
    ///
    /// - Returns: signature key
    public func getTokenSignatureKey() -> Bytes {
        return Array(self.signatureKey.utf8)

    }

    /// Gets token public key
    ///
    /// - Returns: public key
    /// - Throws: if cannot retrieve signature key
    public func getTokenPublicKey() throws -> Bytes {
        return Array(self.publicKey!.utf8)

    }

    /// Generates the expiration date based on the
    /// configured seconds to expire
    ///
    /// - Returns: token expiration date
    /// - Throws: on unable to create the date
    public func generateExpirationDate() -> Date {
        return Date() + self.secondsToExpire

    }

    public func getSigner(key: Bytes) -> Signer {

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

            var key: Bytes = self.getTokenSignatureKey()

            if self.publicKey != nil {

                key = try self.getTokenPublicKey()
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
    ///
    /// - Returns: string with valid JWT token
    public func generateToken(userId: Node) throws -> String {

        // Prepare payload Node
        var payload: Node

        // Prepare contents for payload
        var contents: [Claim] = []

        let subClaim = SubjectClaim(String(describing: userId))

        contents.append(subClaim)

        // Prepare expiration claim if needed
        if self.secondsToExpire > 0 {

            contents.append(ExpirationTimeClaim(self.generateExpirationDate()))

        }

        payload = Node(contents)

        // Generate our Token
        let jwt = try JWT(
            payload: payload,
            signer: self.getSigner(key: self.getTokenSignatureKey())
        )

        // Return the token string
        return try jwt.createToken()

    }

}
