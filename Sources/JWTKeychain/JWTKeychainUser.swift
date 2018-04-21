import Authentication
import Crypto
import Fluent
import Sugar
import Vapor

public protocol AuthenticationPayload: Decodable {
    var password: String { get }
}

public protocol JWTAuthenticatable: Authenticatable {
    associatedtype JWTPayload: JWTKeychainPayload

    /// Authenticates using the supplied credentials and connection.
    static func authenticate(
        using payload: JWTPayload,
        on connection: DatabaseConnectable
    ) throws -> Future<Self?>
}

public protocol JWTCustomPayloadKeychainUser:
    Content,
    HasHashedPassword,
    JWTAuthenticatable
    where Self.Database: QuerySupporting, Self.ID: StringConvertible
{
    associatedtype Login: AuthenticationPayload
    associatedtype Public: ResponseEncodable
    associatedtype Registration: AuthenticationPayload
    associatedtype Update: Decodable

    static func logIn(with: Login, on: DatabaseConnectable) throws -> Future<Self?>
    init(_: Registration) throws

    var password: HashedPassword { get }

    func publicRepresentation() throws -> Public
    func update(using: Update) throws -> Self
}

public protocol JWTKeychainUser: JWTCustomPayloadKeychainUser where JWTPayload == JWTKeychain.Payload {
}

extension JWTCustomPayloadKeychainUser {
    public static func validatePasswordStrength(for password: String) throws {
        // TODO: stricter validation
        guard password.count > 8 else {
            throw JWTKeychainError.weakPassword
        }
    }

    public static var bCryptCost: Int {
        return 4
    }

    public static func authenticate(
        using payload: JWTPayload,
        on connection: DatabaseConnectable
    ) throws -> Future<Self?> {
        return try find(.convertFromString(payload.sub.value), on: connection)
    }

    public static func logIn(on request: Request) throws -> Future<Self> {
        return try request
            .content
            .decode(Login.self)
            .flatMap(to: Self.self) { login in
                return try logIn(with: login, on: request)
                    .map(to: Self.self, userOrNotFound)
                    .map(to: Self.self) { user in
                        guard
                            let created = Data(base64Encoded: user.password.value),
                            try BCrypt.verify(login.password, created: created)
                        else {
                            throw JWTKeychainError.incorrectPassword
                        }

                        return user
                }
        }
    }

//    public static func update(on request: Request) throws ->

    public static func register(on request: Request) throws -> Future<Self> {
        let content = request.content

        return try content
            .decode(Registration.self)
            .flatMap(to: Self.self) { registration in
                return try Self(registration).save(on: request)
            }
    }
}

private func userOrNotFound<U>(_ user: U?) throws -> U {
    guard let user = user else {
        throw JWTKeychainError.userNotFound
    }

    return user
}
