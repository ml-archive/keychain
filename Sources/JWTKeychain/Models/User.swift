import Authentication
import FluentProvider
import JWT
import JWTProvider
import SMTP

/// Defines basic user that can be authorized.
public final class User: Model, Timestampable, SoftDeletable {
    struct Keys {
        static let email = "email"
        static let name = "name"
        static let password = "password"
    }

    public let storage = Storage()

    public private(set) var email: String
    public private(set) var name: String?
    public private(set) var password: String

    /// Initializes the User with name, email and password (plain).
    ///
    /// - parameters:
    ///   - name: name of the user
    ///   - email: email of the user
    ///   - password: password of the user (plain)
    public init(
        email: Valid<UniqueEmail>,
        name: Valid<Name>?,
        password: HashedPassword
    ) {
        self.email = email.value
        self.name = name?.value
        self.password = password.value
    }

    /// Initializer for RowInitializable
    public init(row: Row) throws {
        name = try row.get(Keys.name)
        email = try row.get(Keys.email)
        password = try row.get(Keys.password)
    }

    /// Updates the User with name, email and password.
    /// Only updates non-nil parameters.
    ///
    /// - parameters:
    ///   - name: name of the user
    ///   - email: email of the user
    ///   - password: password of the user
    public func update(
        email: Valid<UniqueEmail>? = nil,
        name: Valid<Name>? = nil,
        password: HashedPassword? = nil
    ) {
        if let email = email {
            self.email = email.value
        }

        if let name = name {
            self.name = name.value
        }

        if let password = password {
            self.password = password.value
        }
    }
}

// MARK: EmailAddressRepresentable

extension User: EmailAddressRepresentable {
    public var emailAddress: EmailAddress {
        return EmailAddress(name: name, address: email)
    }
}

// MARK: JSONRepresentable

extension User: JSONRepresentable {
    public func makeJSON() throws -> JSON {
        var json = JSON()

        try json.set(idKey, id)
        try json.set(Keys.name, name)
        try json.set(Keys.email, email)

        return json
    }
}

// MARK: JWTKeychainAuthenticatable

extension User: JWTKeychainAuthenticatable {

}

// MARK: NodeRepresentable

extension User: NodeRepresentable {

}

// MARK: PasswordAuthenticatable

extension User: PasswordAuthenticatable {
    public static let usernameKey = Keys.email
    public static let passwordKey = Keys.password

    public var hashedPassword: String? {
        return password
    }

    public static var passwordVerifier: PasswordVerifier? {
        return Provider<User>.bCryptHasher
    }
}

// MARK: PasswordUpdateable

extension User: PasswordUpdateable {
    public func updatePassword(to password: String) throws {
        update(password: try Provider<User>.bCryptHasher.hash(Valid(password)))
    }
}

// MARK: PayloadAuthenticatable

extension User: PayloadAuthenticatable {
    public struct UserIdentifier: JSONInitializable {
        let id: Identifier

        public init(json: JSON) throws {
            id = Identifier(try json.get(SubjectClaim.name) as Node)
        }
    }

    public typealias PayloadType = UserIdentifier

    public static func authenticate(_ payload: PayloadType) throws -> User {
        guard let user = try User.find(payload.id) else {
            throw Abort.notFound
        }

        return user
    }
}

// MARK: Preparation

extension User: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.string(Keys.email)
            user.string(Keys.name, optional: true)
            user.string(Keys.password)
        }

        try database.index("email", for: User.self)
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: RequestInitializable

extension User: RequestInitializable {
    
    /// Creates a new user from the values in the request.
    /// - parameters:
    ///   - request: request with values for the keys "email", U.passwordKey
    ///     and optionally "name".
    /// - Throws: Abort error when email and/or password are missing or a
    ///   ValidationError if any of the input is invalid
    /// - Returns: the new user
    public convenience init(request: Request) throws {
        let creds = try User.getCredentials(from: request)

        let name = request.data[Keys.name]?.string

        try self.init(
            email: Valid(creds.username),
            name: name.map(Valid.init),
            password: Provider<User>.bCryptHasher.hash(Valid(creds.password))
        )
    }
}

// MARK: RequestUpdateable

extension User: RequestUpdateable {

    /// Updates an existing user with the values from the request.
    /// - parameters:
    ///   - request: request that optionally contains values for the keys
    ///     "email, "name", and both "password" + "newPassword" in case of a
    ///     password change.
    /// - Throws: when password does not match or user could not be saved
    /// - Returns: the updated user
    public func update(request: Request) throws {
        let data = request.data
        let password: String?
        if
            let newPassword = data["newPassword"]?.string,
            let oldPassword = data[User.passwordKey]?.string,
            let hashedPassword = hashedPassword,
            let verified = try User.passwordVerifier?.verify(
                password: oldPassword,
                matches: hashedPassword
            ),
            verified,
            newPassword != oldPassword
        {
            password = newPassword
        } else {
            password = nil
        }

        let email = data[Keys.email]?.string
        let name = data[Keys.name]?.string

        try update(
            email: email.map(Valid.init),
            name: name.map(Valid.init),
            password: password
                .map(Valid.init) // validate
                .map(Provider<User>.bCryptHasher.hash) // hash
        )
    }
}

// MARK: RowRepresentable
extension User {
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.email, email)
        try row.set(Keys.name, name)
        try row.set(Keys.password, password)
        return row
    }
}
