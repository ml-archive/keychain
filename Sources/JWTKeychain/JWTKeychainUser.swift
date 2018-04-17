import Fluent
import Vapor

public protocol JWTCustomPayloadKeychainUser: Content {
    associatedtype P: JWTKeychainPayload
    static func load(on: Request) throws -> Future<Self>
    func register(on: Request) throws -> Future<Self>
}

public protocol JWTKeychainUser: JWTCustomPayloadKeychainUser where P == Payload {}


extension JWTCustomPayloadKeychainUser where Self: Model, Self.Database: QuerySupporting {
    public func register(on request: Request) throws -> Future<Self> {
        return save(on: request)
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

        return try find(id, on: request).map(to: Self.self) {
            guard let user = $0 else {
                throw JWTKeychainError.userNotFound
            }

            return user
        }
    }
}
