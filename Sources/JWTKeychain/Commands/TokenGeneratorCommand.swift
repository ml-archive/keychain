import Vapor
import Console
import Auth

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
    public let configuration: ConfigurationType
    public init(drop: Droplet, configuration: ConfigurationType) {
        self.drop = drop
        self.console = drop.console
        self.configuration = configuration
    }
    public func run(arguments: [String]) throws {
        console.info("Started the token generator")

        // BUG FIX WHILE WAITING FOR VAPOR UPDATE
        User.database = drop.database

        guard
            arguments.count == 1,
            let user = try User.query().filter("email", arguments[0]).first()
        else {
            print("Bad arguments or user not found with email \(arguments[0])")
            return
        }

        let token = try configuration.generateToken(user: user)
        print("Token generated for user with email \(user.email):")
        print(token)

        console.info("Finished the token generator script")
    }
}
