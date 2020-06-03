import Keychain
import Vapor

struct UserLoginRequest: Decodable, LoginRequest {
    typealias AccessKeychainConfig = UserAccessKeychainConfig
    typealias RefreshKeychainConfig = UserRefreshKeychainConfig

    static let hashedPasswordKey: KeyPath<User, String> = \.hashedPassword

    let password: String

    static func validations(on request: Request) -> EventLoopFuture<Validations> {
        var validations = Validations()
        if request.url.query == "fail" {
            validations.add("validation", result: ValidatorResults.TestFailure())
        }
        return request.eventLoop.future(validations)
    }

    func logIn(on request: Request) -> EventLoopFuture<User> {
        request.eventLoop.future(request.testUser).unwrap(or: TestError.userNotFound)
    }
}
