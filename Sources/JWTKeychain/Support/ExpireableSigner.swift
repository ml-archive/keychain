import Authentication
import Fluent
import Foundation
import Punctual
import JWT
import JWTProvider

public struct ExpireableSigner {
    fileprivate let expirationPeriod: DateComponents
    fileprivate let now: () -> Date
    fileprivate let signer: Signer
    
    public init(
        // injectable for control over dates during testing
        now: @escaping () -> Date = Date.init,
        signerParameters: SignerParameters,
        signerMap: SignerMap
    ) throws {
        guard let signer = signerMap[signerParameters.kid] else {
            throw JWTKeychainError.missingSigner(kid: signerParameters.kid)
        }
        self.signer = signer
        self.now = now
        expirationPeriod = signerParameters.expireIn
    }
}

public protocol TokenGenerator {
    func generateToken<E>(
        for: E
    ) throws -> Token where E: PasswordAuthenticatable, E: Entity
}

extension ExpireableSigner: TokenGenerator {
    public func generateToken<E>(
        for user: E
    ) throws -> Token where E: PasswordAuthenticatable, E: Entity {
        return try Token(
            user: user,
            expirationDate: expirationPeriod.from(now())!,
            signer: signer
        )
    }
}

extension ExpireableSigner: Signer {
    public var name: String {
        return signer.name
    }
    
    public func sign(message: Bytes) throws -> Bytes {
        return try signer.sign(message: message)
    }
    
    public func verify(signature: Bytes, message: Bytes) throws {
        return try signer.verify(signature: signature, message: message)
    }
}
