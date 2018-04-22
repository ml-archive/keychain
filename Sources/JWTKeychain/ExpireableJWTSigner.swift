import Foundation
import JWT

public struct ExpireableJWTSigner {
    let expirationPeriod: TimeInterval
    let signer: JWTSigner

    public init(expirationPeriod: TimeInterval, signer: JWTSigner) {
        self.expirationPeriod = expirationPeriod
        self.signer = signer
    }
}
