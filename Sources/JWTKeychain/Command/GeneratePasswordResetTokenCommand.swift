import Authentication
import Command
import Fluent

public struct GeneratePasswordResetTokenCommand<U: Model & JWTAuthenticatable>:
    Command
where
    U.Database: QuerySupporting,
    U.ID: StringConvertible
{
    public let arguments: [CommandArgument] = [.argument(name: Keys.userId)]
    public let options: [CommandOption] = []

    public let help = ["Generates a password reset token for a user with a given id."]

    private let databaseIdentifier: DatabaseIdentifier<U.Database>

    public init(
        databaseIdentifier: DatabaseIdentifier<U.Database>
    ) {
        self.databaseIdentifier = databaseIdentifier
    }

    public func run(using context: CommandContext) throws -> Future<Void> {
        let userId = try U.ID.convertFromString(context.argument(Keys.userId))

        let signer = try context.container.make(JWTKeychainConfig.self).resetPasswordTokenSigner

        return context
            .container
            .withPooledConnection(to: databaseIdentifier) { connection in
                try U
                    .find(userId, on: connection)
                    .unwrap(or: JWTKeychainError.userNotFound)
                    .flatMap(to: String.self) { user in
                        user.signToken(using: signer, on: connection)
                    }
                    .map {
                        context.console.print("Password Reset Token: \($0)")
                    }
            }
    }
}

private enum Keys {
    static let userId = "userId"
}
