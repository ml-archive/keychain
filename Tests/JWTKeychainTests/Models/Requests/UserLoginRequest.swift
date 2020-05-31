import JWTKeychain
import Vapor

struct UserLoginRequest: Decodable, LoginRequest {
    typealias AccessKeychainConfig = UserAccessKeychainConfig
    typealias RefreshKeychainConfig = UserRefreshKeychainConfig

    static let hashedPasswordKey: KeyPath<User, String> = \.hashedPassword

    let password: String

    func logIn(on request: Request) -> EventLoopFuture<User> {
        request.eventLoop.future(request.testUser).unwrap(or: TestError.userNotFound)
    }
}
