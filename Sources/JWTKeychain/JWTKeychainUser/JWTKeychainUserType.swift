import Authentication
import Crypto
import Fluent
import JWT
import Sugar
import Vapor

public protocol JWTKeychainUserType: JWTCustomPayloadKeychainUserType where
JWTPayload == Payload {}

/// Defines the requirements for user models to be compatible with JWTKeychain.
public protocol JWTCustomPayloadKeychainUserType:
    Creatable,
    JWTAuthenticatable,
    Loginable,
    PublicRepresentable,
    Updatable
where
    Self.Login: Decodable,
    Self.Update: Decodable
{}

extension JWTCustomPayloadKeychainUserType where
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
