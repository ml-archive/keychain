import JWT
import Service

public struct ExpireableJWTSigner {
    let expirationPeriod: TimeInterval
    let signer: JWTSigner

    public init(expirationPeriod: TimeInterval, signer: JWTSigner) {
        self.expirationPeriod = expirationPeriod
        self.signer = signer
    }
}

public struct JWTKeychainConfig: Service {
    public let accessTokenSigner: ExpireableJWTSigner
    public let refreshTokenSigner: ExpireableJWTSigner?
    public let resetPasswordTokenSigner: ExpireableJWTSigner?

    public init(
        accessTokenSigner: ExpireableJWTSigner,
        refreshTokenSigner: ExpireableJWTSigner? = nil,
        resetPasswordTokenSigner: ExpireableJWTSigner? = nil
    ) {
        self.accessTokenSigner = accessTokenSigner
        self.refreshTokenSigner = refreshTokenSigner
        self.resetPasswordTokenSigner = resetPasswordTokenSigner
    }
}
