import JWTKeychain
import Vapor

struct UserController {
    let currentDate: () -> Date

    func login(request: Request) -> EventLoopFuture<AuthenticationResponse<UserResponse>> {
        UserLoginRequest
            .logIn(
                on: request,
                errorOnWrongPassword: TestError.incorrectCredentials,
                currentDate: currentDate()
            ).map { $0.map(UserResponse.init) }
    }

    func register(request: Request) -> EventLoopFuture<AuthenticationResponse<UserResponse>> {
        UserRegisterRequest
            .register(
                on: request,
                currentDate: currentDate()
            ).map {
                request.testUser = $0.user
                return $0.map(UserResponse.init)
            }
    }

    func forgotPassword(request: Request) -> EventLoopFuture<HTTPStatus> {
        UserForgotPasswordRequest
            .sendToken(on: request, currentDate: currentDate())
            .transform(to: .accepted)
    }

    func resetPassword(request: Request) -> EventLoopFuture<HTTPStatus> {
        UserResetPasswordRequest
            .updatePassword(on: request)
            .map { request.testUser = $0}
            .transform(to: .ok)
    }
}

extension UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("login", use: login)
        routes.post("register", use: register)

        let password = routes.grouped("password")
        password.post("forgot", use: forgotPassword)
        password
            .grouped(UserResetKeychainConfig.authenticator)
            .post("reset", use: resetPassword)
    }
}
