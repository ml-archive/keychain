import Vapor
import JWT

private struct JWTKeychainKey: StorageKey {
    typealias Value = Application.JWTKeychain
}

extension Application {
    struct JWTKeychain {
        /// Signer and expiration period for access tokens.
        public let accessTokenSigner: JWTSigner

        /// Signer and expiration period for refresh tokens or nil to opt out of refresh tokens and use
        /// access tokens only.
        public let refreshTokenSigner: JWTSigner?

        /// Endpoints for the routes provided by JWTKeychain.
        public let endpoints: JWTKeychainEndpoints

        /// Determines whether to require authentication on all endpoints (access and refresh).
        public let forceAuthentication: Bool

 
        /// Creates a new JWTKeychain configuration.
        ///
        /// - Parameters:
        ///   - accessTokenSigner: signer and expiration period for access tokens.
        ///   - refreshTokenSigner: signer and expiration period for refresh tokens or nil to opt out of
        ///       refresh tokens and use access tokens only.
        ///   - endpoints: determines the endpoints for the routes
        ///   - shouldRegisterRoutes: determines whether to register the routes for the `endpoints` at
        ///     boot time.
        ///   - forceAuthentication: determines whether to require authentication on all endpoints (access and refresh).
        public init(
            accessTokenSigner: JWTSigner,
            refreshTokenSigner: JWTSigner? = nil,
            endpoints: JWTKeychainEndpoints = .default,
            forceAuthentication: Bool = true
        ) {
            self.accessTokenSigner = accessTokenSigner
            self.refreshTokenSigner = refreshTokenSigner
            self.endpoints = endpoints
            self.forceAuthentication = forceAuthentication
        }
    }
}
