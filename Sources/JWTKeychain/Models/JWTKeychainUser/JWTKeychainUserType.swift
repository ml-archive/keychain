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
    Model,
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
        return try container.future(Payload(
            exp: ExpirationClaim(value: expirationTime),
            sub: SubjectClaim(value: requireID().description)
        ))
    }
}
