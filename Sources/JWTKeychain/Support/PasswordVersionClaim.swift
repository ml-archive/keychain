import Authentication
import JWT
import Vapor

/// This claim is used to store the password version of a user in a JWT.
/// It is used with resetting passwords to see whether the User's password has
/// not already been changed.
public struct PasswordVersionClaim: EqualityClaim, StringBacked {
    public static let name = "nodes:pwd"

    public let value: String

    public init(string: String) {
        self.value = string
    }

    public init(user: PasswordUpdateable) throws {
        self.init(string: "\(user.passwordVersion)")
    }
}
