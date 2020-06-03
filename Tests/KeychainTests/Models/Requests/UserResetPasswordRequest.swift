import Keychain
import Vapor

struct UserResetPasswordRequest: Decodable, ResetPasswordRequest {
    static let hashedPasswordKey = \User.hashedPassword

    let password: String

    static func validations(on request: Request) -> EventLoopFuture<Validations> {
        var validations = Validations()
        if request.url.query == "fail" {
            validations.add("validation", result: ValidatorResults.TestFailure())
        }
        return request.eventLoop.future(validations)
    }
}
