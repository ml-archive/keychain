import Authentication
import Command
import Fluent

public struct GeneratePasswordResetTokenCommand<
    U: JWTAuthenticatable
>:
    Command
where
    U.Database: QuerySupporting
{
    public let arguments: [CommandArgument] = [.argument(name: Keys.query)]
    public let options: [CommandOption] = []

    public let help = ["Generates a password reset token for a user with a given id."]

    private let databaseIdentifier: DatabaseIdentifier<U.Database>
    private let makeFilter: (String) throws -> ModelFilter<U>

    public init(
        databaseIdentifier: DatabaseIdentifier<U.Database>,
        makeFilter: @escaping (String) throws -> ModelFilter<U>
    ) {
        self.databaseIdentifier = databaseIdentifier
        self.makeFilter = makeFilter
    }

    public func run(using context: CommandContext) throws -> Future<Void> {
        let signer = try context.container.make(JWTKeychainConfig.self).resetPasswordTokenSigner

        return context
            .container
            .withPooledConnection(to: databaseIdentifier) { connection in
                try U
                    .query(on: connection)
                    .filter(self.makeFilter(context.argument(Keys.query)))
                    .first()
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

extension GeneratePasswordResetTokenCommand where U.ID: StringConvertible {
    public init(
        databaseIdentifier: DatabaseIdentifier<U.Database>
    ) {
        self.databaseIdentifier = databaseIdentifier
        self.makeFilter = { query -> ModelFilter<U> in
            try U.idKey == U.ID.convertFromString(query)
        }
    }
}

private enum Keys {
    static let query = "query"
}
