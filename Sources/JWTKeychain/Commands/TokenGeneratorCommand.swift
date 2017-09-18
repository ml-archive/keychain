import Authentication
import Console
import JWT
import JWTProvider
import Vapor

/// Generates a token for a user with a given email that can be used to reset
/// their password.
///
/// - usage: `vapor run --generateToken [email]`
public final class TokenGeneratorCommand: Command {
    internal enum TokenGeneratorError: Error {
        case missingEmail
        case missingJWTProvider
        case userNotFound
    }

    public let id = "keychain:generate_token"
    public let help: [String] = [
        "Generates a JWT token by passing in the user's email."
    ]
    public let console: ConsoleProtocol
    public let tokenGenerator: ExpireableSigner
    
    internal init(
        console: ConsoleProtocol,
        tokenGenerator: ExpireableSigner
    ) {
        self.console = console
        self.tokenGenerator = tokenGenerator
    }

    public func run(arguments: [String]) throws {
        console.info("Started the token generator")

        guard let email = arguments.first else {
            throw TokenGeneratorError.missingEmail
        }

        guard let user = try User
            .makeQuery()
            .filter("email", email)
            .first() else {
                throw TokenGeneratorError.userNotFound
        }

        let token = try tokenGenerator.generateToken(for: user)
        
        console.info("Token generated for user with email \(user.email):")
        console.print(token.string)

        console.success("Finished the token generator script")
    }
}
