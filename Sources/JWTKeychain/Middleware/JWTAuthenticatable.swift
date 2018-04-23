import Authentication
import JWT
import Vapor

public protocol JWTAuthenticatable: Authenticatable {
    associatedtype JWTPayload: JWTKeychainPayload

    /// Authenticates using the supplied payload and connection.
    ///
    /// - Parameters:
    ///   - payload: a payload containing user identifiable information
    ///   - connection: the connection which which to load the user
    /// - Returns: the authenticated user or nil, in the future.
    static func authenticate(
        using payload: JWTPayload,
        on connection: DatabaseConnectable
    ) throws -> Future<Self?>

    /// Makes JWT Payload that is able to identify the user during authentication.
    ///
    /// - Parameters:
    ///   - expirationTime: time until which the JWT containing this payload is valid
    ///   - container: a container that can be used to access services
    /// - Returns: JWT Payload that is able to identify the user
    func makePayload(
        expirationTime: Date,
        on container: Container
    ) -> Future<JWTPayload>
}

extension JWTAuthenticatable {
    func signToken(
        using signer: ExpireableJWTSigner,
        currentTime: Date = .init(),
        on container: Container
    ) -> Future<String> {
        return makePayload(expirationTime: currentTime + signer.expirationPeriod, on: container)
            .map(to: String?.self) {
                var jwt = JWT(payload: $0)
                return try String(bytes: jwt.sign(using: signer.signer), encoding: .utf8)
            }.unwrap(or: JWTKeychainError.signingError)
    }
}
