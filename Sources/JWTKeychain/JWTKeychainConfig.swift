import JWT

public struct JWTKeychainConfig {
    public init() {}
    
    func makeSigner() -> JWTSigner {
        return .hs256(key: "secret".convertToData())
    }
}
