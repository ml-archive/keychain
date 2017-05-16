import Authentication
import FluentProvider
import Foundation
import protocol JWT.Storable
import JWT
import JWTProvider
import Sugar
import Vapor

/// Defines basic user that can be authorized.
public final class User: Model, Timestampable, SoftDeletable {
    public let storage = Storage()

    public var name: String?
    public var email: String
    public var password: String

    /// Initializes the User with name, email and password (plain)
    ///
    /// - Parameters:
    ///   - name: name of the user
    ///   - email: email of the user
    ///   - password: password of the user (plain)
    public init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        // TODO: implement hashing
        self.password = "" //BCrypt.hash(password: password)
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
