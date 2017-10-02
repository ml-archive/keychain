import Authentication
import Console
import Fluent
import JWT
import JWTProvider
import Vapor

public typealias TokenGeneratableUser = Entity & PasswordAuthenticatable

/// Generates a token for a user with a given username (generally email) that
/// can be used to reset their password.
///
/// - usage: `vapor run --generateToken [username]`
public final class TokenGeneratorCommand<U: TokenGeneratableUser>: Command {
    internal enum TokenGeneratorError: Error {
        case missingUsername
        case missingJWTProvider
        case userNotFound
    }

    public let id = "keychain:generate_token"
    public let help: [String] = [
        "Generates a JWT token by passing in the user's username (eg. email)."
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

        guard let username = arguments.first else {
            throw TokenGeneratorError.missingUsername
        }

        guard let user = try U
            .makeQuery()
            .filter(U.usernameKey, username)
            .first() else {
                throw TokenGeneratorError.userNotFound
        }

        let token = try tokenGenerator.generateToken(for: user)

        console.info("Token generated for user with username \(username):")
        console.print(token.string)

        console.success("Finished the token generator script")
    }
}

// MARK: ConfigInitializable

extension TokenGeneratorCommand: ConfigInitializable {
    public convenience init(config: Config) throws {
        let tokenGenerators = try TokenGenerators(
            settings: Settings(config: config),
            signerMap: config.assertSigners()
        )

        try self.init(
            console: config.resolveConsole(),
            tokenGenerator: tokenGenerators.resetPassword
        )
    }
}
