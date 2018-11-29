import Vapor

public struct JWTKeychainController<U: JWTCustomPayloadKeychainUserType> {
    public init() {}

    public func logIn(req: Request) throws -> Future<UserResponse<U>> {
        return try U
            .logIn(on: req)
            .flatMap(to: UserResponse<U>.self) { user in
                try self.makeUserResponse(for: user, withOptions: .all, on: req)
            }
    }

    public func me(req: Request) throws -> Future<U.Public> {
        return try req.requireAuthenticated(U.self).convertToPublic(on: req)
    }

    public func register(req: Request) throws -> Future<UserResponse<U>> {
        return try U
            .register(on: req)
            .flatMap(to: UserResponse<U>.self) { user in
                try self.makeUserResponse(for: user, withOptions: .all, on: req)
            }
    }

    public func token(req: Request) throws -> Future<UserResponse<U>> {
        return try self.makeUserResponse(
            for: req.requireAuthenticated(U.self),
            withOptions: .accessToken,
            on: req
        )
    }

    public func update(req: Request) throws -> Future<U.Public> {
        return try U.update(on: req)
            .flatMap { try $0.convertToPublic(on: req) }
    }
}
