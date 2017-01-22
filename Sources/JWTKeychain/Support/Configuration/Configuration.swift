import Foundation
import Vapor
import HTTP
import VaporJWT
import Auth

/// Sets the protocol of what is expected on the config file
public protocol ConfigurationType {

    func validateToken(token: String) throws -> Bool
    func generateToken(user: UserType, extraClaims: Claim...) throws -> String
    func generateResetPasswordToken(user: UserType) throws -> String
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

    /// Seconds the reset password token has to expire (in the future)
    private var secondsToExpireResetPassword: Double

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

        guard let secondsToExpireResetPassword = jwtConfig["secondsToExpireResetPassword"]?.double else {
            throw Error.missingConfig("secondsToExpireResetPassword")
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
            resetPasswordEmail: resetPasswordEmail,
            secondsToExpireResetPassword: secondsToExpireResetPassword
        )

    }

    public init(signer: String, signatureKey: String, publicKey: String?, secondsToExpire: Double, resetPasswordEmail: String, secondsToExpireResetPassword: Double){
        self.signer = signer
        self.signatureKey = signatureKey
        self.publicKey = publicKey
        self.secondsToExpire = secondsToExpire
        self.resetPasswordEmail = resetPasswordEmail
        self.secondsToExpireResetPassword = secondsToExpireResetPassword
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
    public func generateToken(user: UserType, extraClaims: Claim...) throws -> String {

        // Extract user info into Node
        let userInfo = try user.makeJWTNode()

        // Prepare claims
        var claims: [Claim] = []

        // Prepare expiration claim if needed. If we added an expiration time claim
        // DO NOT override it
        if self.secondsToExpire > 0 && !extraClaims.contains(where: { $0 is ExpirationTimeClaim }) {
            
            claims.append(ExpirationTimeClaim(self.generateExpirationDate()))
            
        }

        // Add the claims passed into the method
        claims.append(contentsOf: extraClaims)

        // Add user info
        claims.append(UserClaim(userInfo))

        let claimNode = Node(claims)

        // Generate our Token
        let jwt = try JWT(
            payload: claimNode,
            signer: self.getSigner(key: self.signatureKeyBytes)
        )
        
        // Return the token string
        return try jwt.createToken()
        
    }

    /// Generates the reset password token with the settings provided on the 
    /// config
    ///
    /// - Parameter user: user to generate the token
    /// - Returns: token string
    /// - Throws: not able to generate token
    public func generateResetPasswordToken(user: UserType) throws -> String {

        // Make a token that expires in
        let expiryClaim = ExpirationTimeClaim(Date() + self.secondsToExpireResetPassword)
        return try self.generateToken(user: user, extraClaims: expiryClaim)

    }
    
}
