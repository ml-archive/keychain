import Crypto
import Fluent
import JWT
import Vapor

/// Defines the requirements for user models to be compatible with JWTKeychain.
public protocol JWTKeychainUserType: Model, PublicRepresentable {}
//    Creatable,
//    JWTAuthenticatable,
//    Loginable,
//    Model,
//    PublicRepresentable,
//    Updatable
//where
//    Self.Login: Codable,
//    Self.Update: Codable
//{}

//extension JWTKeychainUserType where
//    Self: Model
//{
//    /// See `JWTAuthenticatable`.
//    public func makePayload(
//        expirationTime: Date,
//        on container: Container
//    ) throws -> Future<Payload> {
//        return try container.future(Payload(
//            exp: ExpirationClaim(value: expirationTime),
//            sub: SubjectClaim(value: requireID().description)
//        ))
//    }
//}
