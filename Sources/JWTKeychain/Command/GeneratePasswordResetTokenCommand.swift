import Authentication
import Command
import Fluent

/// Generates password reset tokens for a user which can be used to reset their password.
public struct GeneratePasswordResetTokenCommand<U: JWTAuthenticatable>: Command where
    U.Database: QuerySupporting
{
    /// See `Command`
    public let arguments: [CommandArgument] = [.argument(name: Keys.query)]

    /// See `CommandRunnable`
    public let options: [CommandOption] = []

    /// See `CommandRunnable`
    public let help = ["Generates a password reset token for a user with a given id."]

    /// See `CommandRunnable`
    private let makeFilter: (String) throws -> ModelFilter<U>

    private let databaseIdentifier: DatabaseIdentifier<U.Database>

    /// Creates a new password reset token command with a custom lookup strategy.
    ///
    /// Example to enable search by email:
    /// ```
    /// GeneratePasswordResetTokenCommand(databaseIdentifier: .mysql) { query in
    ///     try \User.email == $0
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - databaseIdentifier: identifier of database from where to load the user
    ///   - makeFilter: used to create the filter from the query
    public init(
        databaseIdentifier: DatabaseIdentifier<U.Database>,
        makeFilter: @escaping (String) throws -> ModelFilter<U>
    ) {
        self.databaseIdentifier = databaseIdentifier
        self.makeFilter = makeFilter
    }

    /// See `CommandRunnable`
    public func run(using context: CommandContext) throws -> Future<Void> {
        let signer = try context.container.make(JWTKeychainConfig.self).resetPasswordTokenSigner

        let container = context.container

        return container.withPooledConnection(to: databaseIdentifier) { connection in
            try U
                .query(on: connection)
                .filter(self.makeFilter(context.argument(Keys.query)))
                .first()
                .unwrap(or: JWTKeychainError.userNotFound)
                .flatMap(to: String.self) { user in
                    user.signToken(using: signer, on: container)
                }
                .map {
                    context.console.print("Password Reset Token: \($0)")
                }
        }
    }
}

extension GeneratePasswordResetTokenCommand where U.ID: StringConvertible {

    /// Creates a new password reset token command that looks up users by database identifier.
    ///
    /// - Parameter databaseIdentifier: identifier of database from where to load the user
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
