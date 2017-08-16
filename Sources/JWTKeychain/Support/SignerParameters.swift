import Configs

public struct SignerParameters {
    let kid: String
    let secondsToExpire: Int
    
    public init?(config: Config) {
        guard
            let kid = config["kid"]?.string,
            let secondsToExpire = config["secondsToExpire"]?.int else {
                return nil
        }
        
        self.init(kid: kid, secondsToExpire: secondsToExpire)
    }
    
    public init(kid: String, secondsToExpire: Int) {
        self.kid = kid
        self.secondsToExpire = secondsToExpire
    }
}
