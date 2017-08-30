import Authentication
import JWT
import Vapor

/// This claim is used to store the password hash of a user in an JWT.
/// It is used with resetting passwords to see whether the User's password has
/// not already been changed.
internal struct PasswordClaim: EqualityClaim, StringBacked {
    static let name = "nodes:pwd"
    
    let value: String
    
    init(string: String) {
        self.value = string
    }
    
    init(user: PasswordAuthenticatable) throws {
        guard let hashedPassword = user.hashedPassword else {
            throw Abort.serverError
        }
        
        self.init(string: hashedPassword)
    }
}
