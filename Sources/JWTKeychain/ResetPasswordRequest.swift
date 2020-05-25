import Vapor

public protocol ResetPasswordRequest: ValidatableRequest {
    associatedtype Model

    static var hashedPasswordKey: ReferenceWritableKeyPath<Model, String> { get }

    var password: String { get }
}

public extension ResetPasswordRequest {
    static func updatePassword(for user: Model, on request: Request) -> EventLoopFuture<Model> {
        do {
            return request
                .password
                .async
                .hash(try Self(request: request).password)
                .map {
                    user[keyPath: Self.hashedPasswordKey] = $0
                    return user
                }
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}

public extension ResetPasswordRequest where Model: Authenticatable {
    static func updatePassword(on request: Request) -> EventLoopFuture<Model> {
        do {
            return updatePassword(for: try request.auth.require(), on: request)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}
