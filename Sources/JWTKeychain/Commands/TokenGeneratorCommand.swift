import Authentication
import Console
import JWT
import JWTProvider
import Vapor

public final class TokenGeneratorCommand: Command {
    enum TokenGeneratorError: Error {
        case wrongArguments
    }

    public let id = "generator:token"
    public let help: [String] = [
        "Generates a JWT token by passing in the user's email."
    ]
    public let console: ConsoleProtocol
    public let drop: Droplet

    public init(drop: Droplet) {
        self.drop = drop
        self.console = drop.console
    }

    public func run(arguments: [String]) throws {
        console.info("Started the token generator")

        // TODO: is this still relevant?
        // BUG FIX WHILE WAITING FOR VAPOR UPDATE
        User.database = drop.database

        guard
            arguments.count == 1,
            let user = try User.makeQuery().filter("email", arguments[0]).first()
        else {
            print("Bad arguments or user not found with email \(arguments[0])")
            return
        }

        let token = try user.createToken(using: try drop.assertSigner())
        print("Token generated for user with email \(user.email):")
        print(token)

        console.info("Finished the token generator script")
    }
}
