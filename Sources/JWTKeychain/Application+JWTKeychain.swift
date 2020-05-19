import Vapor
import JWT

fileprivate struct JWTKeychainKey: StorageKey {
    typealias Value = Application.JWTKeychain
}

extension Application {
    struct JWTKeychain {
        /// Signer and expiration period for access tokens.
        public let accessTokenSigner: JWTSigner
        
        /// Signer and expiration period for refresh tokens or nil to opt out of refresh tokens and use
        /// access tokens only.
        public let refreshTokenSigner: JWTSigner? = nil
    }
    
    var jtwKeychain: JWTKeychain? {
        get { storage[JWTKeychainKey.self] }
        
        set { storage[JWTKeychainKey.self] = newValue }
    }
}
