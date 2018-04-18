import JWT
import Service

public struct JWTKeychainConfig: Service {
    public let accessTokenSigner: JWTSigner
    public let refreshTokenSigner: JWTSigner?
    public let resetPasswordTokenSigner: JWTSigner?

    public init(
        accessTokenSigner: JWTSigner,
        refreshTokenSigner: JWTSigner? = nil,
        resetPasswordTokenSigner: JWTSigner? = nil
    ) {
        self.accessTokenSigner = accessTokenSigner
        self.refreshTokenSigner = refreshTokenSigner
        self.resetPasswordTokenSigner = resetPasswordTokenSigner
    }
}
