import Authentication
import Vapor

public protocol JWTAuthenticatable: Authenticatable {
    associatedtype JWTPayload: JWTKeychainPayload

    /// Authenticates using the supplied credentials and connection.
    static func authenticate(
        using payload: JWTPayload,
        on connection: DatabaseConnectable
    ) throws -> Future<Self?>

    /// Makes JWT Payload that is able to identify the user during authentication.
    ///
    /// - Parameters:
    ///   - expirationTime: time until which the JWT containing this payload is valid
    ///   - on: The current request
    /// - Returns: JWT Payload that is able to identify the user
    func makePayload(
        expirationTime: Date,
        on: DatabaseConnectable
    ) -> Future<JWTPayload>
}
