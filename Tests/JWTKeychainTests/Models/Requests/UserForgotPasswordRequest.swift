import JWTKeychain
import Vapor

struct UserForgotPasswordRequest: Decodable, ForgotPasswordRequest {
    typealias Config = UserResetKeychainConfig

    let name: String

    static func sendToken(
        _ token: String,
        user: User,
        config: Config,
        request: Request
    ) -> EventLoopFuture<Void> {
        request.application.mail.sendToken(token, to: user, using: config)
        return request.eventLoop.future()
    }

    func findUser(request: Request) -> EventLoopFuture<User?> {
        request.eventLoop.future(request.testUser)
    }
}

