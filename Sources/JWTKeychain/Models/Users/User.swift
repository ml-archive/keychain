import Authentication
import BCrypt
import FluentProvider
import Foundation
import protocol JWT.Storable
import JWT
import JWTProvider
import SMTP
import Sugar
import Vapor

/// Defines basic user that can be authorized.
public final class User: Model, Timestampable, SoftDeletable {
    public let storage = Storage()

    public var name: String?
    public var email: String
    public var password: String

    // TODO: only accept Valid<Name>, email, password etc.
    /// Initializes the User with name, email and password (plain)
    ///
    /// - Parameters:
    ///   - name: name of the user
    ///   - email: email of the user
    ///   - password: password of the user (plain)
    public init(name: String?, email: String, password: String) throws {
        self.name = name
        self.email = email
        // TODO: salt this hash
        self.password = try Hash.make(message: password).makeString()
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// Initializer for RowInitializable
    public init(row: Row) throws {
        self.name = try row.get("name")
        self.email = try row.get("email")
        self.password = try row.get("password")
    }
}

// MARK: - RowRepresentable
extension User {
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", self.name)
        try row.set("email", self.email)
        try row.set("password", self.password)
        return row
    }
}

// MARK: - Vapor Model
extension User {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.string("name")
            user.string("email")
            user.string("password")
        }

        try database.index(table: "users", column: "email", name: "users_email_index")
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
public struct UserIdentifier: JSONInitializable {
    let id: Identifier

    public init(json: JSON) throws {
        id = Identifier(try json.get(User.name) as Node)
    }
}

extension User: PayloadAuthenticatable {
    public typealias PayloadType = UserIdentifier

    public static func authenticate(_ payload: PayloadType) throws -> User {
        guard let user = try User.find(payload.id) else {
            throw Abort.init(.badRequest, reason: "User not found")
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

extension User: NodeRepresentable {}

extension User: HasEmail {}

extension User: JSONRepresentable {
    public func makeJSON() throws -> JSON {
        var json = JSON()

        try json.set("id", id)
        try json.set("name", name)
        try json.set("email", email)

        return json
    }
}

extension User: EmailAddressRepresentable {
    public var emailAddress: EmailAddress {
        return EmailAddress(name: name, address: email)
    }
}

extension User: UserAuthenticating {
    public convenience init(request: Request) throws {
        let data = request.data

        guard
            let email = data["email"]?.string,
            let password = data["password"]?.string else {
                throw Abort.badRequest
        }

        try self.init(
            name: data["name"]?.string,
            email: email,
            password: password)
    }

    public static func update(request: Request) throws -> Self {
        let data = request.data
        let user = try findById(request: request)

        if let newName = data["name"]?.string {
            user.name = newName
        }

        if let newEmail = data["email"]?.string {
            user.email = newEmail
        }

        if
            let newPassword = data["new_password"]?.string,
            let oldPassword = data["password"]?.string,
            newPassword != oldPassword {
            // TODO: check password and update new password
        }

        try user.save()

        return user
    }
}
