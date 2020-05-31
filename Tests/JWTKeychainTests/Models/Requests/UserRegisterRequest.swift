import JWTKeychain
import Vapor

struct UserRegisterRequest: Decodable, RegisterRequest {
    typealias AccessKeychainConfig = UserAccessKeychainConfig
    typealias RefreshKeychainConfig = UserRefreshKeychainConfig

    let name: String
    let password: String

    func register(on request: Request) -> EventLoopFuture<User> {
        request.password.async.hash(password).map { hashedPassword in
            User(name: self.name, hashedPassword: hashedPassword)
        }
    }
}
