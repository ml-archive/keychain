import Vapor

public protocol RegisterRequest: AuthenticationRequest, ValidatableRequest {
    typealias Model = User

    func register(on request: Request) -> EventLoopFuture<AccessKeychainConfig.JWTPayload.User>
}

public extension RegisterRequest {
    static func register(
        on request: Request,
        currentDate: Date = Date()
    ) -> EventLoopFuture<AuthenticationResponse<Model>> {
        validated(on: request).flatMap { registerRequest in
            registerRequest.register(on: request)
        }.flatMapThrowing { user in
            try authenticationResponse(for: user, on: request, currentDate: currentDate)
        }
    }
}
