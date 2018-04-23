import Authentication
import Crypto
import Fluent
import JWT
import Sugar
import Vapor

public protocol JWTKeychainUser:
    JWTCustomPayloadKeychainUser
where
    JWTPayload == JWTKeychain.Payload
{}

extension JWTKeychainUser {
    public func makePayload(
        expirationTime: Date,
        on container: Container
    ) -> Future<Payload> {
        return Future.map(on: container) {
            try JWTPayload(
                exp: ExpirationClaim(value: expirationTime),
                sub: SubjectClaim(value: self.requireID().convertToString())
            )
        }
    }
}

// MARK: - JWTCustomPayloadKeychainUser

public protocol JWTCustomPayloadKeychainUser:
    Content,
    HasHashedPassword,
    JWTAuthenticatable,
    PublicRepresentable
where
    Self.Database: QuerySupporting,
    Self.ID: StringConvertible
{
    associatedtype Login: PasswordPayload
    associatedtype Registration: PasswordPayload
    associatedtype Update: Decodable

    static func logIn(with: Login, on: DatabaseConnectable) throws -> Future<Self?>
    init(_: Registration) throws

    func update(using: Update) throws
}

extension JWTCustomPayloadKeychainUser {
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
                try logIn(with: login, on: request)
                    .unwrap(or: JWTKeychainError.userNotFound)
                    .map(to: Self.self) { user in
                        guard
                            try BCrypt.verify(login.password, created: user.password.value)
                        else {
                            throw JWTKeychainError.incorrectPassword
                        }

                        return user
                    }
            }
    }

    public static func register(on request: Request) throws -> Future<Self> {
        let content = request.content

        return try content
            .decode(Registration.self)
            .flatMap(to: Self.self) { registration in
                return try Self(registration).save(on: request)
            }
    }
}
