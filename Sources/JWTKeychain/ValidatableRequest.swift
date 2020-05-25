import Vapor
//TODO: replace this with Submissions
public protocol ValidatableRequest: RequestInitializable {
    static func validations(on request: Request) -> EventLoopFuture<Validations>
}

public extension ValidatableRequest {
    static func validations(on request: Request) -> EventLoopFuture<Validations> {
        request.eventLoop.future(Validations())
    }
}

public extension ValidatableRequest where Self: Validatable {
    static func validations(on request: Request) -> EventLoopFuture<Validations> {
        request.eventLoop.future(validations())
    }
}

public extension ValidatableRequest {
    static func validated(on request: Request) -> EventLoopFuture<Self> {
        validations(on: request).flatMapThrowing { validations in
            try validations.validate(request).assert()
            return try Self(request: request)
        }
    }
}
