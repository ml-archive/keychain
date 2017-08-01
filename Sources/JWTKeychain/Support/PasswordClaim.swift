import Authentication
import JWT
import Vapor

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
