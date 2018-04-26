import Service
import Sugar

public struct JWTKeychainConfig: Service {
    public let accessTokenSigner: ExpireableJWTSigner
    public let refreshTokenSigner: ExpireableJWTSigner?
    public let endpoints: JWTKeychainEndpoints
    public let shouldRegisterRoutes: Bool

    /// Creates a new JWTKeychain configuration.
    ///
    /// - Parameters:
    ///   - accessTokenSigner: signer and expiration period for access tokens
    ///   - refreshTokenSigner: signer and expiration period for refresh tokens or nil to opt out of
    ///       refresh tokens and use access tokens only.
    ///   - endpoints: determines the endpoints for the routes
    ///   - shouldRegisterRoutes: determines whether to register the default routes at boot time
    public init(
        accessTokenSigner: ExpireableJWTSigner,
        refreshTokenSigner: ExpireableJWTSigner? = nil,
        endpoints: JWTKeychainEndpoints = .default,
        shouldRegisterRoutes: Bool = true
    ) {
        self.accessTokenSigner = accessTokenSigner
        self.refreshTokenSigner = refreshTokenSigner
        self.endpoints = endpoints
        self.shouldRegisterRoutes = shouldRegisterRoutes
    }
}
