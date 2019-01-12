import Authentication
import Crypto
import Fluent
import JWT
import Sugar
import Vapor

/// Defines the requirements for user models to be compatible with JWTKeychain.
public protocol JWTKeychainUserType:
    Creatable,
    JWTAuthenticatable,
    Loginable,
    PublicRepresentable,
    Updatable
where
    Self.Login: Decodable,
    Self.Update: Decodable
{}

extension JWTKeychainUserType where
    Self: Model,
    JWTPayload == Payload,
    Self.ID: LosslessStringConvertible
{
    /// See `JWTAuthenticatable`.
    public func makePayload(
        expirationTime: Date,
        on container: Container
    ) throws -> Future<Payload> {
        return Future.map(on: container) {
            try Payload(
                exp: ExpirationClaim(value: expirationTime),
                sub: SubjectClaim(value: self.requireID().description)
            )
        }
    }
}
