import Authentication
import Crypto
import Fluent
import JWT
import Sugar
import Vapor

public protocol JWTKeychainUserType: JWTCustomPayloadKeychainUserType where
    JWTPayload == Payload
{}

extension JWTKeychainUserType {
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
