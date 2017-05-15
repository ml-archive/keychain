import Foundation
import Vapor
import HTTP
import JWT
import Authentication

/// Sets the protocol of what is expected on the config file
public protocol ConfigurationType {

    /// Validates a given token
    ///
    /// - Parameter token: string with the token
    /// - Throws: if unable to create JWT instance or if token is invalid
    func validateToken(token: String) throws

    /// Generates a token for the user
    /// - Parameter: userId is used to create a SubjectClaim
    /// - Parameter: extraClaims are optional customized claims
    /// - Returns: string with valid JWT token
    func generateToken<T: UserType>(user: T, extraClaims: Claim...) throws -> String

    /// Generates the reset password token with the settings provided on the
    /// config
    ///
    /// - Parameter user: user to generate the token
    /// - Returns: token string
    /// - Throws: not able to generate token
    func generateResetPasswordToken<T: UserType>(user: T) throws -> String

    /// Returns the path to the reset password view
    ///
    /// - Returns: path
    func getResetPasswordEmaiView() -> String

    /// Returns number of seconds that the token will expire in
    ///
    /// - Returns: seconds
    func getResetPasswordTokenExpirationTime() -> Double

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
    public var resetPasswordEmail: String

    /// Seconds the reset password token has to expire (in the future)
    private var secondsToExpireResetPassword: Double

    public enum Error: Swift.Error {
        case noJWTConfig
        case missingConfig(String)
        case invalidClaims
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

    public func validateToken(token: String) throws {
        do {
            // Validate our current access token
            let receivedJWT = try JWT(token: token)

            var key: Bytes = self.signatureKeyBytes

            if let publicKeyBytes = self.publicKeyBytes {
                key = publicKeyBytes
            }

            // Verify signature
            let signer: Signer = self.getSigner(key: key)
            try receivedJWT.verifySignature(using: signer)

            // If we have expiration set on config, verify it
            if self.secondsToExpire > 0 {
                try receivedJWT.verifyClaims([ExpirationTimeClaim()])
            }
        } catch {
            throw AuthenticationError.invalidBearerAuthorization
        }
    }

     public func generateToken(node: Node, extraClaims: [Claim]) throws -> String {
        // Prepare claims
        var claims: [Claim] = []
        
        // Prepare expiration claim if needed. If we added an expiration time claim
        // DO NOT override it
        if self.secondsToExpire > 0 && !extraClaims.contains(where: { $0 is ExpirationTimeClaim }) {
            
            claims.append(ExpirationTimeClaim(date: self.generateExpirationDate()))

        }
        
        // Add the claims passed into the method
        claims.append(contentsOf: extraClaims)
        
        // Add user info
        claims.append(UserClaim(node))
        
        let claimNode = Node(claims)
        
        // Generate our Token
        let jwt = try JWT(
            payload: JSON(claimNode),
            signer: self.getSigner(key: self.signatureKeyBytes)
        )
        
        // Return the token string
        return try jwt.createToken()
    }
    
    public func generateToken(node: Node, extraClaims: Claim...) throws -> String {
        return try generateToken(node: node, extraClaims: extraClaims)
    }
    
    public func generateToken<T: UserType>(user: T, extraClaims: Claim...) throws -> String {
        return try generateToken(node: user.makeJWTNode(), extraClaims: extraClaims)
    }

    public func generateResetPasswordToken<T: UserType>(user: T) throws -> String {

        // Make a token that expires in
        let expiryClaim = ExpirationTimeClaim(date: Date() + self.secondsToExpireResetPassword)
        return try self.generateToken(user: user, extraClaims: expiryClaim)
    }

    public func getResetPasswordEmaiView() -> String {
        return self.resetPasswordEmail
    }

    public func getResetPasswordTokenExpirationTime() -> Double {
        return self.secondsToExpireResetPassword
    }
    
}
