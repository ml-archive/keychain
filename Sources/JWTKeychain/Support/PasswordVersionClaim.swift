import Authentication
import JWT
import Vapor

/// This claim is used to store the password version of a user in a JWT.
/// It is used with resetting passwords to see whether the User's password has
/// not already been changed.
internal struct PasswordVersionClaim: EqualityClaim, StringBacked {
    internal static let name = "nodes:pwd"
    
    internal let value: String
    
    internal init(string: String) {
        self.value = string
    }
    
    internal init(user: PasswordUpdateable) throws {
        self.init(string: "\(user.passwordVersion)")
    }
}
