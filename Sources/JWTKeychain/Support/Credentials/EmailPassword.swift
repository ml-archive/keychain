import Turnstile

/// Represents User credentials by combination of email and password
public class EmailPassword: Credentials {
    
    /// Email address
    public let email: String
    
    /// Password (plain)
    public let password: String
    
    
    /// Initializes the credentials
    ///
    /// - Parameters:
    ///   - email: user email
    ///   - password: user password
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
