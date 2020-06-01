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

    func refreshToken(request: Request) throws -> Response {
        let token = try UserRefreshKeychainConfig.makeToken(on: request, currentDate: currentDate())

        // here we encode the token string as JSON but you might include your token in a struct
        // conforming to `Content`
        let response = Response()
        try response.content.encode(token, as: .json)
        return response
    }

    func me(request: Request) throws -> UserResponse {
        try .init(user: request.auth.require(User.self))
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

        routes
            .grouped(UserRefreshKeychainConfig.authenticator)
            .post("token", use: refreshToken)
        routes
            .grouped(UserAccessKeychainConfig.authenticator)
            .get("me", use: me)
    }
}
