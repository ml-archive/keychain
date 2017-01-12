import Vapor

public final class Provider: Vapor.Provider {
    
    /// Seconds the JWT has to expire (in the future)
    public var secondsToExpire: Double? = nil

    /// Key used to sign the JWT
    public var signatureKey: String

    /// Public Key used to sign the JWT
    public var publicKey: String? = nil

    /// Signer used to sign the JWT
    public var signer: String

    public enum Error: Swift.Error {
        case noJWTConfig
        case missingConfig(String)
    }
    
    convenience public init(drop: Droplet) throws {
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
        
        self.signer = signer
        self.secondsToExpire = secondsToExpire
        self.signatureKey = signatureKey
        self.publicKey = publicKey

    }
    
    public init(signer: String, signatureKey: String, publicKey: String?, secondsToExpire: Double) throws {
        self.signer = signer
        self.signatureKey = signatureKey
        self.publicKey = publicKey
        self.secondsToExpire = secondsToExpire
    }
    
    public func boot(_ drop: Droplet) {
        do {
            try Configuration.boot(signer: self.signer, signatureKey: self.signatureKey, publicKey: self.publicKey, secondsToExpire: self.secondsToExpire!)
        } catch {
            print("JWTKeyChain boot - Failed to load config \(error)")
        }
    }
    
    /**
     Called after the Droplet has completed
     initialization and all provided items
     have been accepted.
     */
    public func afterInit(_ drop: Droplet) {
        
    }
    
    /**
     Called before the Droplet begins serving
     which is @noreturn.
     */
    public func beforeRun(_ drop: Droplet) {
        
    }
}
