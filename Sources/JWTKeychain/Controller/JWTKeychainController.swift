import Sugar
import Vapor

public protocol JWTKeychainControllerType {
    func logIn(req: Request) throws -> Future<Response>
    func me(req: Request) throws -> Future<Response>
    func register(req: Request) throws -> Future<Response>
    func token(req: Request) throws -> Future<Response>
    func update(req: Request) throws -> Future<Response>
}

open class JWTKeychainController<U: JWTCustomPayloadKeychainUserType>: JWTKeychainControllerType {
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
            .update(on: req)
            .flatMap { try $0.convertToPublic(on: req) }
            .encode(for: req)
    }
}
