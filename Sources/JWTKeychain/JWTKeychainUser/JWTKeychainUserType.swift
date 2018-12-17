import Authentication
import Crypto
import Fluent
import JWT
import Sugar
import Vapor

public protocol JWTKeychainUserType: JWTCustomPayloadKeychainUserType where
    JWTPayload == Payload
{}

extension JWTCustomPayloadKeychainUserType where JWTPayload == Payload {
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

// MARK: - JWTCustomPayloadKeychainUser

public protocol JWTCustomPayloadKeychainUserType:
    Creatable,
    Content,
    HasPassword,
    JWTAuthenticatable,
    Loginnable,
    Model,
    PasswordAuthenticatable,
    PublicRepresentable,
    Updatable
where
    Self.ID: LosslessStringConvertible,
    Self.Create: Decodable,
    Self.Login: Decodable,
    Self.Update: Decodable
{}
