import Vapor

public final class JWTProvider: Vapor.Provider {
    
    /// Seconds the JWT has to expire (in the future)
    public var secondsToExpire: Double? = nil
    
    /// Key used to sign the JWT
    public var signatureKey: String? = nil
    
    public enum Error: Swift.Error {
        case noJWTConfig
        case missingConfig(String)
    }
    
    public init(config: Config) throws {
        
        guard let jwtConfig = config["jwt"]?.object else {
            throw Error.noJWTConfig
        }
    
        guard let secondsToExpire = jwtConfig["secondsToExpire"]?.double else {
            throw Error.missingConfig("secondsToExpire")
        }
        
        guard let signatureKey = jwtConfig["signatureKey"]?.string else {
            throw Error.missingConfig("signatureKey")
        }
        
        
        self.secondsToExpire = secondsToExpire
        self.signatureKey = signatureKey

    }
    
    public init(signatureKey: String, secondsToExpire: Double) throws {
        
        self.secondsToExpire = secondsToExpire
        self.signatureKey = signatureKey
    }
    
    public func boot(_ drop: Droplet) throws {
        
        try Configuration.boot(secondsToExpire: self.secondsToExpire!, signatureKey: self.signatureKey!)
        
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
