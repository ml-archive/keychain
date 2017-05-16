import Authentication
import FluentProvider
import Foundation
import protocol JWT.Storable
import JWT
import JWTProvider
import Sugar
import Vapor

/// Defines basic user that can be authorized.
public final class User: Model {
    public let storage = Storage()

    public var exists: Bool = false

    public var name: String?
    public var email: String
    public var password: String

    // TODO: conform to Timestampable
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    
//    /// Initializes the User with name, email and password (plain)
//    ///
//    /// - Parameters:
//    ///   - validated: an instance of `StoreRequest` that has a name, email and password.
//    public required init(validated: StoreRequest) {
//        name = validated.name
//        email = validated.email
//        password = BCrypt.hash(password: validated.password)
//        createdAt = Date()
//        updatedAt = Date()
//    }

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

    public init(row: Row) throws {
        self.name = try row.get("name")
        self.email = try row.get("email")
        self.password = try row.get("password")

        if let createdAt: String = try row.get("created_at") {
            self.createdAt = Date.parse(.dateTime, createdAt)
        }

        if let updatedAt: String = try row.get("updated_at") {
            self.updatedAt = Date.parse(.dateTime, updatedAt)
        }

        if let deletedAt: String = try row.get("deleted_at") {
            self.deletedAt = Date.parse(.dateTime, deletedAt)
        }
    }
}

extension User {
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", self.name)
        try row.set("email", self.email)
        try row.set("password", self.password)
        try row.set("created_at", self.createdAt?.to(.dateTime))
        try row.set("updated_at", self.updatedAt?.to(.dateTime))
        try row.set("deleted_at", self.deletedAt?.to(.dateTime))
        return row
    }
}

// MARK: - Authorization and registration
//extension User {
//
//    /// Authenticates the user with the given credentials
//    ///
//    /// - Parameter credentials: user credentials
//    /// - Returns: authenticated User
//    /// - Throws: if we can't get the User
//    public static func authenticate(credentials: Credentials) throws -> Auth.User {
//        var user: User?
//
//        switch credentials {
//
//        case let credentials as EmailPassword:
//
//            if let fetchedUser = try User.query().filter("email", credentials.email).first(){
//                let passwordMatches = try? BCrypt.verify(password: credentials.password, matchesHash: fetchedUser.password)
//
//                if passwordMatches == true {
//                    user = fetchedUser
//                }
//            }
//
//        case let credentials as Identifier:
//
//            user = try User.find(credentials.id)
//
//        case let credentials as Auth.AccessToken:
//
//            let token = try JWT(token: credentials.string)
//
//            if let userId =  token.payload["user"]?.object?["id"]?.int {
//                user = try User.query().filter("id", userId).first()
//            }
//
//        default:
//            throw UnsupportedCredentialsError()
//        }
//
//        if let user = user {
//
//            return user
//
//        } else {
//            throw IncorrectCredentialsError()
//        }
//    }
//
//    public static func register(credentials: Credentials) throws -> Auth.User {
//
//        var newUser: User
//
//        switch credentials {
//        case let credentials as EmailPassword:
//            newUser = User(credentials: credentials)
//
//        default: throw UnsupportedCredentialsError()
//        }
//
//        if try User.query().filter("email", newUser.email).first() == nil {
//
//            try newUser.save()
//
//            return newUser
//        } else {
//            throw AccountTakenError()
//        }
//    }
//}


// MARK: - Vapor Model
extension User {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.string("name")
            user.string("email")
            user.string("password")
            // TODO: conform to Timestampable
//            user.timestamps()
            // TODO: conform to SoftDeletable
//            user.softDelete()
        }

        try database.index(table: "users", column: "email", name: "users_email_index")
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: Storable {
    public static let name = "user"

    public var node: Node {
        return id?.makeNode(in: nil) ?? ""
    }
}

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
