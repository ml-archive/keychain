import Vapor

public protocol LoginRequest: AuthenticationRequest, ValidatableRequest {
    typealias Model = User

    static var hashedPasswordKey: KeyPath<Model, String> { get }

    var password: String { get }

    func logIn(on request: Request) -> EventLoopFuture<Model>
}

public extension LoginRequest {
    static func logIn(
        on request: Request,
        errorOnWrongPassword: @escaping @autoclosure () -> Error,
        currentDate: Date = Date()
    ) -> EventLoopFuture<AuthenticationResponse<Model>> {
        validated(on: request).flatMap { loginRequest in
            loginRequest
                .logIn(on: request)
                .flatMap { user in
                    request.password.async
                        .verify(loginRequest.password, created: user[keyPath: hashedPasswordKey])
                        .flatMapThrowing { passwordsMatch in
                            guard passwordsMatch else { throw errorOnWrongPassword() }

                            return try authenticationResponse(
                                for: user,
                                on: request,
                                currentDate: currentDate
                            )
                        }
                }
        }
    }
}
