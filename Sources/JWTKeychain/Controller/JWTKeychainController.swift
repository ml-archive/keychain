import Sugar
import Vapor

/// Determines which routes a controller for JWTKeychain should implement.
public protocol JWTKeychainControllerType {
    func logIn(req: Request) throws -> Future<Response>
    func me(req: Request) throws -> Future<Response>
    func register(req: Request) throws -> Future<Response>
    func token(req: Request) throws -> Future<Response>
    func update(req: Request) throws -> Future<Response>
}

/// Controller for JWTKeychain with default implementations. Can be subclassed in case some of the
/// routes need custom behavior.
open class JWTKeychainController<U: JWTKeychainUserType>: JWTKeychainControllerType {
    public init() {}

    open func logIn(req: Request) throws -> Future<Response> {
        return try U
            .logIn(on: req)
            .flatMap(to: UserResponse<U>.self) { user in
                try self.makeUserResponse(for: user, withOptions: .all, on: req)
            }
            .encode(for: req)
    }

    open func me(req: Request) throws -> Future<Response> {
        return try req
            .requireAuthenticated(U.self)
            .convertToPublic(on: req)
            .encode(for: req)
    }

    open func register(req: Request) throws -> Future<Response> {
        return try U
            .create(on: req)
            .flatMap(to: UserResponse<U>.self) { user in
                try self.makeUserResponse(for: user, withOptions: .all, on: req)
            }
            .encode(for: req)
    }

    open func token(req: Request) throws -> Future<Response> {
        return try self
            .makeUserResponse(
                for: req.requireAuthenticated(U.self),
                withOptions: .accessToken,
                on: req
            )
            .encode(for: req)
    }

    open func update(req: Request) throws -> Future<Response> {
        return try req
            .requireAuthenticated(U.self)
            .applyUpdate(on: req)
            .flatMap { try $0.convertToPublic(on: req) }
            .encode(for: req)
    }
}
