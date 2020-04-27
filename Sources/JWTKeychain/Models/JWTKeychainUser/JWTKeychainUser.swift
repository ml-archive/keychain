import FluentMySQL
import Sugar
import Vapor

/// Basic implementation for a JWTKeychain compatible user.
public final class JWTKeychainUser: Codable {
    public var id: Int?
    public var email: String
    public var name: String
    public var password: String
    public var passwordChangeCount: Int

    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?

    public init(
        id: Int? = nil,
        email: String,
        name: String,
        password: String,
        passwordChangeCount: Int = 0
    ) throws {
        self.id = id
        self.email = email
        self.name = name
        self.password = password
        self.passwordChangeCount = passwordChangeCount
    }
}

extension JWTKeychainUser: Content {}
extension JWTKeychainUser: HasPassword {}
extension JWTKeychainUser: Migration {}
extension JWTKeychainUser: MySQLModel {
    public typealias Database = MySQLDatabase
    public static let createdAtKey: TimestampKey? = \.createdAt
    public static let updatedAtKey: TimestampKey? = \.updatedAt
    public static let deletedAtKey: TimestampKey? = \.deletedAt
}
extension JWTKeychainUser: Parameter {}
