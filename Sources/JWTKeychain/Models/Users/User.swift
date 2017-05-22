import Authentication
import FluentProvider
import protocol JWT.Storable
import JWT
import JWTProvider
import SMTP
import Sugar

/// Defines basic user that can be authorized.
public final class User: Model, HasEmail, Timestampable, SoftDeletable {
    struct Keys {
        static let email = "email"
        static let name = "name"
        static let password = "password"
    }

    public let storage = Storage()

    public var email: String
    public var name: String?
    public var password: String

    /// Initializes the User with name, email and password (plain).
    ///
    /// - Parameters:
    ///   - name: name of the user
    ///   - email: email of the user
    ///   - password: password of the user (plain)
    public init(
        email: Valid<Email>,
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

    /// Updates the User with name, email and password. Only updates non-nil parameters.
    ///
    /// - Parameters:
    ///   - name: name of the user
    ///   - email: email of the user
    ///   - password: password of the user
    func update(
        email: Valid<Email>?,
        name: Valid<Name>?,
        password: HashedPassword?
    ) throws -> Self {
        if let email = email {
            self.email = email.value
        }

        if let name = name {
            self.name = name.value
        }

        if let password = password {
            self.password = password.value
        }

        try save()
        return self
    }
}

// MARK: - RowRepresentable
extension User {
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.email, email)
        try row.set(Keys.name, name)
        try row.set(Keys.password, password)
        return row
    }
}

// MARK: - Vapor Model
extension User {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.string(Keys.email)
            user.string(Keys.name)
            user.string(Keys.password)
        }

        try database.index(table: "users", column: Keys.email, name: "users_email_index")
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JWT.Storable
extension User: Storable {
    public var node: Node {
        return id?.makeNode(in: nil) ?? ""
    }
}

// MARK: - PayloadAuthenticatable
extension User: PayloadAuthenticatable {
    public struct UserIdentifier: JSONInitializable {
        let id: Identifier

        public init(json: JSON) throws {
            id = Identifier(try json.get(User.name) as Node)
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

extension User: TokenCreating {
    public func createToken(using signer: Signer) throws -> Token {
        let jwt = try JWT(
            payload: JSON(self as Storable),
            signer: signer
        )
        // TODO: should JWT include a version of createToken that returns a Token instead of a String?
        return Token(string: try jwt.createToken())
    }
}

extension User: JSONRepresentable, NodeRepresentable {
    public func makeJSON() throws -> JSON {
        var json = JSON()

        try json.set(idKey, id)
        try json.set(Keys.name, name)
        try json.set(Keys.email, email)

        return json
    }
}

extension User: EmailAddressRepresentable {
    public var emailAddress: EmailAddress {
        return EmailAddress(name: name, address: email)
    }
}
