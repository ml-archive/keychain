import Crypto
import Fluent
import Vapor

public protocol JWTUserRegistration: Decodable {
    var password: String { get }
}

public protocol JWTCustomPayloadKeychainUser: Content {
    associatedtype P: JWTKeychainPayload

    static var passwordKey: KeyPath<Self, HashedPassword> { get }
    static var userIdentifierKey: KeyPath<Self, String> { get }

    static var bCryptCost: Int { get }

    static func load(on: Request) throws -> Future<Self>
    static func logIn(on: Request) throws -> Future<Self>
    static func register(on: Request) throws -> Future<Self>

    associatedtype R: JWTUserRegistration

    init(_: R) throws
}

extension JWTCustomPayloadKeychainUser {
    public static var bCryptCost: Int {
        return 4
    }
}

public protocol JWTKeychainUser: JWTCustomPayloadKeychainUser where P == Payload {}

extension JWTCustomPayloadKeychainUser where Self: Model, Self.Database: QuerySupporting, Self: Content {
    public static func logIn(on request: Request) throws -> Future<Self> {
        guard
            let userIdentifierProperty = try reflectProperty(forKey: userIdentifierKey),
            let passwordProperty = try reflectProperty(forKey: passwordKey)
        else {
            // TODO: better error?
            throw JWTKeychainError.invalidIdentifier
        }

        let content = request.content

        return flatMap(
            to: Self.self,
            content[String.self, at: userIdentifierProperty.path],
            content[String.self, at: passwordProperty.path]
        ) { userIdentifier, password in
            return try query(on: request)
                .filter(userIdentifierKey, .equals, .data(userIdentifier))
                .first()
                .map(to: Self.self, userOrNotFound)
                .map(to: Self.self) { user in
                    guard
                        let password = password,
                        let created = Data(base64Encoded: user[keyPath: passwordKey].value),
                        try BCrypt.verify(password, created: created)
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
            .decode(R.self)
            .flatMap(to: Self.self) { registration in
                if registration.password.count < 8 {
                    throw JWTKeychainError.weakPassword
                }
                return try Self(registration).save(on: request)
            }
    }
}

extension JWTCustomPayloadKeychainUser where
    Self: Model, Self.Database: QuerySupporting, Self.ID: StringInitializable
{
    public static func load(on request: Request) throws -> Future<Self> {
        let payload: P = try request.payload()

        guard let id = ID(string: payload.sub.value) else {
            throw JWTKeychainError.invalidIdentifier
        }

        return try find(id, on: request).map(to: Self.self, userOrNotFound)
    }
}

private func userOrNotFound<U>(_ user: U?) throws -> U {
    guard let user = user else {
        throw JWTKeychainError.userNotFound
    }

    return user
}
