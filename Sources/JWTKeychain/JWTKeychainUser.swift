import Crypto
import Fluent
import Vapor

public protocol JWTKeychainUserLogin: Decodable {
    var password: String { get }
}

public protocol JWTKeychainUserPublic: Encodable {}

public protocol JWTKeychainUserRegistration: Decodable {
    var password: String { get }
}

public protocol JWTKeychainUserUpdate: Decodable {}

public protocol JWTCustomPayloadKeychainUser: Content, Model where
    Self.Database: QuerySupporting, Self.ID: StringInitializable
{
    associatedtype Login: JWTKeychainUserLogin
    associatedtype Payload: JWTKeychainPayload
//    associatedtype Public: JWTKeychainUserPublic
    associatedtype Registration: JWTKeychainUserRegistration
//    associatedtype Update: JWTKeychainUserUpdate

    static var bCryptCost: Int { get }

    static func logIn(with: Login, on: Request) throws -> Future<Self?>
    init(_: Registration) throws

    var password: HashedPassword { get }

//    func asPublic() throws -> Public
//    func update(_ : Update) throws -> Self
}

extension JWTCustomPayloadKeychainUser {
    public static var bCryptCost: Int {
        return 4
    }
}

public protocol JWTKeychainUser: JWTCustomPayloadKeychainUser where Payload == JWTKeychain.Payload {}

extension JWTCustomPayloadKeychainUser {
    public static func load(on request: Request) throws -> Future<Self> {
        let payload: Payload = try request.payload()

        guard let id = ID(string: payload.sub.value) else {
            throw JWTKeychainError.invalidIdentifier
        }

        return try find(id, on: request).map(to: Self.self, userOrNotFound)
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

    public static func register(on request: Request) throws -> Future<Self> {
        let content = request.content

        return try content
            .decode(Registration.self)
            .flatMap(to: Self.self) { registration in
                if registration.password.count < 8 {
                    throw JWTKeychainError.weakPassword
                }
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
