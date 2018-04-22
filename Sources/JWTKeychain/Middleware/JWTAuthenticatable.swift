import Authentication
import JWT
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

extension JWTAuthenticatable {
    func signToken(
        using signer: ExpireableJWTSigner,
        currentTime: Date = .init(),
        on connection: DatabaseConnectable
    ) -> Future<String> {
        return makePayload(expirationTime: currentTime + signer.expirationPeriod, on: connection)
            .map(to: String?.self) {
                var jwt = JWT(payload: $0)
                return try String(bytes: jwt.sign(using: signer.signer), encoding: .utf8)
            }.unwrap(or: JWTKeychainError.signingError)
    }
}
