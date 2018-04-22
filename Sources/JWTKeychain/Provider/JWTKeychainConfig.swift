import Service

public struct JWTKeychainConfig: Service {
    public let accessTokenSigner: ExpireableJWTSigner
    public let refreshTokenSigner: ExpireableJWTSigner?
    public let resetPasswordTokenSigner: ExpireableJWTSigner

    public let endpoints: JWTKeychainEndpoints

    public let shouldRegisterRoutes: Bool

    /// Creates a new JWTKeychain configuration
    ///
    /// - Parameters:
    ///   - accessTokenSigner: signer and expiration period for access tokens
    ///   - refreshTokenSigner: signer and expiration period for refresh tokens or nil to opt out of
    ///       refresh tokens and use access tokens only.
    ///   - resetPasswordTokenSigner: signer and expiration period for password reset tokens
    ///   - shouldRegisterRoutes: determines whether to register the default routes at boot time
    public init(
        accessTokenSigner: ExpireableJWTSigner,
        refreshTokenSigner: ExpireableJWTSigner? = nil,
        resetPasswordTokenSigner: ExpireableJWTSigner,
        shouldRegisterRoutes: Bool = true,
        endpoints: JWTKeychainEndpoints = .default
    ) {
        self.accessTokenSigner = accessTokenSigner
        self.refreshTokenSigner = refreshTokenSigner
        self.resetPasswordTokenSigner = resetPasswordTokenSigner
        self.shouldRegisterRoutes = shouldRegisterRoutes
        self.endpoints = endpoints
    }
}
