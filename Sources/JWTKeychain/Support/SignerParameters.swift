import Configs
import Foundation

public struct SignerParameters {
    internal let kid: String
    internal let expireIn: DateComponents
    
    public init?(config: Config) {
        guard
            let kid = config["kid"]?.string,
            let secondsToExpire = config["secondsToExpire"]?.int else {
                return nil
        }
        
        self.init(kid: kid, expireIn: secondsToExpire.seconds)
    }
    
    public init(kid: String, expireIn: DateComponents = 1.hour) {
        self.kid = kid
        self.expireIn = expireIn
    }
}
