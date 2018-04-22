import Service

public struct JWTKeychainConfig: Service {
    public let accessTokenSigner: ExpireableJWTSigner
    public let refreshTokenSigner: ExpireableJWTSigner?
    public let resetPasswordTokenSigner: ExpireableJWTSigner?

    public let shouldRegisterRoutes: Bool

    public init(
        accessTokenSigner: ExpireableJWTSigner,
        refreshTokenSigner: ExpireableJWTSigner? = nil,
        resetPasswordTokenSigner: ExpireableJWTSigner? = nil,
        shouldRegisterRoutes: Bool = true
    ) {
        self.accessTokenSigner = accessTokenSigner
        self.refreshTokenSigner = refreshTokenSigner
        self.resetPasswordTokenSigner = resetPasswordTokenSigner
        self.shouldRegisterRoutes = shouldRegisterRoutes
    }
}
