import Service
import Sugar

/// Configuration for the JWTKeychain Provider.
public struct JWTKeychainConfig<U: JWTKeychainUserType>: Service {

    /// Signer and expiration period for access tokens.
    public let accessTokenSigner: ExpireableJWTSigner

    /// Signer and expiration period for refresh tokens or nil to opt out of refresh tokens and use
    /// access tokens only.
    public let refreshTokenSigner: ExpireableJWTSigner?

    /// Endpoints for the routes provided by JWTKeychain.
    public let endpoints: JWTKeychainEndpoints

    /// Determines whether to require authentication on all endpoints (access and refresh).
    public let forceAuthentication: Bool

    /// The controller that holds the logic for the routes.
    public let controller: JWTKeychainControllerType

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
        accessTokenSigner: ExpireableJWTSigner,
        refreshTokenSigner: ExpireableJWTSigner? = nil,
        endpoints: JWTKeychainEndpoints = .default,
        forceAuthentication: Bool = true,
        controller: JWTKeychainControllerType = JWTKeychainController<U>()
    ) {
        self.accessTokenSigner = accessTokenSigner
        self.refreshTokenSigner = refreshTokenSigner
        self.endpoints = endpoints
        self.forceAuthentication = forceAuthentication
        self.controller = controller
    }
}
