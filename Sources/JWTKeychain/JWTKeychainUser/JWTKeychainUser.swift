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
                sub: SubjectClaim(value: self.requireID().convertToString())
            )
        }
    }
}

// MARK: - JWTCustomPayloadKeychainUser

public protocol JWTCustomPayloadKeychainUser:
    Content,
    HasPassword,
    JWTAuthenticatable,
    PublicRepresentable
where
    Self.Database: QuerySupporting,
    Self.ID: StringConvertible
{
    associatedtype Login: HasPasswordString
    associatedtype Registration: HasPasswordString
    associatedtype Update: Decodable

    static func logIn(with: Login, on: DatabaseConnectable) throws -> Future<Self?>
    init(_: Registration) throws

    func update(using: Update) throws
}

extension JWTCustomPayloadKeychainUser {
    public static func authenticate(
        using payload: JWTPayload,
        on connection: DatabaseConnectable
    ) throws -> Future<Self?> {
        return try find(.convertFromString(payload.sub.value), on: connection)
    }

    public static func logIn(on req: Request) throws -> Future<Self> {
        return try req
            .content
            .decode(Login.self)
            .flatMap(to: Self.self) { login in
                try logIn(with: login, on: req)
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

    public static func register(on req: Request) throws -> Future<Self> {
        let content = req.content

        return try content
            .decode(Registration.self)
            .flatMap(to: Self.self) { registration in
                return try Self(registration).save(on: req)
            }
    }
}

extension Model where Database: QuerySupporting {
    static func requireFind(_ id: ID, on worker: DatabaseConnectable) throws -> Future<Self> {
        return try Self
            .find(id, on: worker)
            .unwrap(or: Abort(.notFound, reason: "\(Self.self) with id \(id) not found"))
    }
}
