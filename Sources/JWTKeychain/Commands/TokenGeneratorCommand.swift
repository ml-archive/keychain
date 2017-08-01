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
    enum TokenGeneratorError: Error {
        case missingEmail
        case missingJWTProvider
        case userNotFound
    }

    public let id = "generateToken"
    public let help: [String] = [
        "Generates a JWT token by passing in the user's email."
    ]
    public let console: ConsoleProtocol
    public let signer: Signer
    private let now: () -> Date
    
    internal init(
        console: ConsoleProtocol,
        signer: Signer,
        now: @escaping () -> Date
    ) {
        self.console = console
        self.signer = signer
        self.now = now
    }

    convenience public init(console: ConsoleProtocol, signer: Signer) {
        self.init(console: console, signer: signer, now: Date.init)
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

        let token = try Token(
            user: user,
            expirationDate: 1.hour.from(now())!,
            signer: signer
        )
        
        console.info("Token generated for user with email \(user.email):")
        console.print(token.string)

        console.success("Finished the token generator script")
    }
}

// MARK: ConfigInitializable

extension TokenGeneratorCommand: ConfigInitializable {
    public convenience init(config: Config) throws {
        guard let jwtProvider = config.providers.first(where: {
            $0 is JWTProvider.Provider
        }) as? JWTProvider.Provider else {
            throw TokenGeneratorError.missingJWTProvider
        }

        let console = try config.resolveConsole()
        let signer = jwtProvider.signer
        self.init(console: console, signer: signer)
    }
}
