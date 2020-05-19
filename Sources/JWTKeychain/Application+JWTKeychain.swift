import Vapor
import JWTKit

extension Application {
    public struct JWTKeychain {
        /// Signer and expiration period for access tokens.
        public let accessTokenSigner: JWTSigner
        
        /// Signer and expiration period for refresh tokens or nil to opt out of refresh tokens and use
        /// access tokens only.
        public let refreshTokenSigner: JWTSigner? = nil
    }
    
    fileprivate struct Key: StorageKey {
        typealias Value = JWTKeychain
    }
    
    public var jwtKeychain: JWTKeychain? {
        get { storage[Key.self] }
        set { storage[Key.self] = newValue }
    }
}
