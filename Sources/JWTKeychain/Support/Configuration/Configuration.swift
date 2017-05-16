//import Authentication
//import Foundation
//import HTTP
//import JWT
//import Vapor
//
///// Sets the protocol of what is expected on the config file
//public protocol ConfigurationType {
//
//    /// Returns the path to the reset password view
//    ///
//    /// - Returns: path
//    func getResetPasswordEmailView() -> String
//
//    /// Returns number of seconds that the token will expire in
//    ///
//    /// - Returns: seconds
//    func getResetPasswordTokenExpirationTime() -> Double
//
//}
//
//public struct Configuration: ConfigurationType {
//
//    /// Seconds the JWT has to expire (in the future)
//    private var secondsToExpire: Double
//
//    /// Key used to sign the JWT
//    private var signatureKey: String
//
//    /// Key used to check the signing the JWT
//    private var publicKey: String? = nil
//
//    /// Which signer will be used while signing the JWT
//    private var signer: String
//
//    /// The path to the reset password email
//    public var resetPasswordEmail: String
//
//    /// Seconds the reset password token has to expire (in the future)
//    private var secondsToExpireResetPassword: Double
//
//    public enum Error: Swift.Error {
//        case noJWTConfig
//        case missingConfig(String)
//        case invalidClaims
//    }
//
//    public init(drop: Droplet) throws {
//        try self.init(config: drop.config)
//    }
//
//    public init(config: Config) throws {
//
//        guard let jwtConfig = config["jwt"]?.object else {
//            throw Error.noJWTConfig
//        }
//
//        guard let signer: String = jwtConfig["signer"]?.string else {
//            throw Error.missingConfig("signer")
//        }
//
//        guard let secondsToExpire = jwtConfig["secondsToExpire"]?.double else {
//            throw Error.missingConfig("secondsToExpire")
//        }
//
//        guard let signatureKey = jwtConfig["signatureKey"]?.string else {
//            throw Error.missingConfig("signatureKey")
//        }
//
//        guard let resetPasswordEmail = jwtConfig["resetPasswordEmail"]?.string else {
//            throw Error.missingConfig("resetPasswordEmail")
//        }
//
//        guard let secondsToExpireResetPassword = jwtConfig["secondsToExpireResetPassword"]?.double else {
//            throw Error.missingConfig("secondsToExpireResetPassword")
//        }
//
//        let publicKey: String? = jwtConfig["publicKey"]?.string
//
//        if publicKey == nil {
//            //The ECDSA and RSA (ES*/RS*) signers take a private key for signing and needs a matching public key for verifying.
//            if signer.hasPrefix("ES") || signer.hasPrefix("RS"){
//                throw Error.missingConfig("publicKey")
//            }
//        }
//
//        self.init(
//            signer: signer,
//            signatureKey: signatureKey,
//            publicKey: publicKey,
//            secondsToExpire: secondsToExpire,
//            resetPasswordEmail: resetPasswordEmail,
//            secondsToExpireResetPassword: secondsToExpireResetPassword
//        )
//
//    }
//
//    public init(signer: String, signatureKey: String, publicKey: String?, secondsToExpire: Double, resetPasswordEmail: String, secondsToExpireResetPassword: Double){
//        self.signer = signer
//        self.signatureKey = signatureKey
//        self.publicKey = publicKey
//        self.secondsToExpire = secondsToExpire
//        self.resetPasswordEmail = resetPasswordEmail
//        self.secondsToExpireResetPassword = secondsToExpireResetPassword
//    }
//
//    /// Generates the expiration date based on the
//    /// configured seconds to expire
//    ///
//    /// - Returns: token expiration date
//    /// - Throws: on unable to create the date
//    public func generateExpirationDate() -> Date {
//        return Date() + self.secondsToExpire
//    }
//
//    public func getResetPasswordEmailView() -> String {
//        return self.resetPasswordEmail
//    }
//
//    public func getResetPasswordTokenExpirationTime() -> Double {
//        return self.secondsToExpireResetPassword
//    }
//    
//}
