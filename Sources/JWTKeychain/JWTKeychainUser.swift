import Fluent
import Vapor

public protocol JWTCustomPayloadKeychainUser: Content {
    associatedtype P: JWTKeychainPayload
    static func load(on: Request) throws -> Future<Self>
}

public protocol JWTKeychainUser: JWTCustomPayloadKeychainUser where P == Payload {}

extension JWTCustomPayloadKeychainUser where Self: Model, Self.Database: QuerySupporting {
    public static func load(
        on request: Request,
        transformId: @escaping (String) -> ID?
    ) throws -> Future<Self> {
        let payload: P = try request.payload()

        guard let id = transformId(payload.sub.value) else {
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

extension JWTCustomPayloadKeychainUser where
    Self: Model, Self.Database: QuerySupporting, Self.ID == Int
{
    public static func load(on request: Request) throws -> Future<Self> {
        return try load(on: request, transformId: Int.init)
    }
}

extension JWTCustomPayloadKeychainUser where
    Self: Model, Self.Database: QuerySupporting, Self.ID == String
{
    public static func load(on request: Request) throws -> Future<Self> {
        return try load(on: request, transformId: String.init)
    }
}

extension JWTCustomPayloadKeychainUser where
    Self: Model, Self.Database: QuerySupporting, Self.ID == UUID
{
    public static func load(on request: Request) throws -> Future<Self> {
        return try load(on: request) { UUID($0) }
    }
}
