import Authentication
import Crypto
import Fluent
import JWT
import Sugar
import Vapor

public protocol JWTKeychainUser: JWTCustomPayloadKeychainUser where
    JWTPayload == Payload
{}

extension JWTKeychainUser {
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

public protocol JWTCustomPayloadKeychainUser:
    Content,
    HasPassword,
    JWTAuthenticatable,
    Model,
    PasswordAuthenticatable,
    PublicRepresentable,
    UserType
where
    Self.ID: LosslessStringConvertible
{}
