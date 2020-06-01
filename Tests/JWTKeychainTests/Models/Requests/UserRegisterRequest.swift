import JWTKeychain
import Vapor

struct UserRegisterRequest: Decodable, RegisterRequest {
    typealias AccessKeychainConfig = UserAccessKeychainConfig
    typealias RefreshKeychainConfig = UserRefreshKeychainConfig

    let name: String
    let password: String

    static func validations(on request: Request) -> EventLoopFuture<Validations> {
        var validations = Validations()
        if request.url.query == "fail" {
            validations.add("validation", result: ValidatorResults.TestFailure())
        }
        return request.eventLoop.future(validations)
    }

    func register(on request: Request) -> EventLoopFuture<User> {
        request.password.async.hash(password).map { hashedPassword in
            User(name: self.name, hashedPassword: hashedPassword)
        }
    }
}
