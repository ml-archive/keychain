import JWT
import Service

//struct ExpireableJWTSigner {
//    let expirationTime: TimeInterval
//    let signer: JWTSigner
//}

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
