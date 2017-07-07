import Authentication
import Console
import JWT
import JWTProvider
import Vapor

public final class TokenGeneratorCommand: Command {
    enum TokenGeneratorError: Error {
        case missingEmail
        case missingJWTProvider
        case userNotFound
    }

    public let id = "generator:token"
    public let help: [String] = [
        "Generates a JWT token by passing in the user's email."
    ]
    public let console: ConsoleProtocol
    public let signer: Signer

    public init(console: ConsoleProtocol, signer: Signer) {
        self.console = console
        self.signer = signer
    }

    public func run(arguments: [String]) throws {
        console.info("Started the token generator")

        guard let email = arguments.first else {
            throw TokenGeneratorError.missingEmail
        }

        guard let user = try User.makeQuery().filter("email", email).first() else {
            throw TokenGeneratorError.userNotFound
        }

        let token = try Token(user: user, expirationDate: 1.hour.fromNow, signer: signer)
        console.info("Token generated for user with email \(user.email):")
        console.print(token.string)

        console.success("Finished the token generator script")
    }
}

extension TokenGeneratorCommand: ConfigInitializable {
    public convenience init(config: Config) throws {
        try self.init(console: config.resolveConsole(), signer: config.assertSigner())
    }
}
