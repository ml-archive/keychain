import JWTKeychain
import Vapor

struct UserResetPasswordRequest: Decodable, ResetPasswordRequest {
    static let hashedPasswordKey = \User.hashedPassword

    let password: String
}
