import Authentication
import Fluent
import Foundation
import Punctual
import JWT
import JWTProvider

public struct ExpireableSigner {
    private let expirationPeriod: DateComponents
    internal let signer: Signer // TODO: this should not have to be internal
    private let now: () -> Date
    
    init(
        now: @escaping () -> Date = Date.init, // injectable for control over dates during testing
        signerParameters: SignerParameters,
        signerMap: SignerMap
    ) throws {
        guard let signer = signerMap[signerParameters.kid] else {
            throw JWTKeychainError.missingSigner(kid: signerParameters.kid)
        }
        self.signer = signer
        self.now = now
        expirationPeriod = signerParameters.secondsToExpire.seconds
    }
    
    public func generateToken<E: Entity>(
        for user: E
        ) throws -> Token where E: PasswordAuthenticatable {
        return try Token(
            user: user,
            expirationDate: expirationPeriod.from(now())!,
            signer: signer
        )
    }
}
