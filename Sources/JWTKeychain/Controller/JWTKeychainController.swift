import Vapor

/// Determines which routes a controller for JWTKeychain should implement.
public protocol JWTKeychainControllerType {
    func logIn(req: Request) throws -> EventLoopFuture<Response>
    func me(req: Request) throws -> EventLoopFuture<Response>
    func register(req: Request) throws -> EventLoopFuture<Response>
    func token(req: Request) throws -> EventLoopFuture<Response>
    func update(req: Request) throws -> EventLoopFuture<Response>
}
