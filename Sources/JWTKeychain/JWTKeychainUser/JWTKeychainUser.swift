import FluentMySQL
import Vapor

public final class JWTKeychainUser: Codable {
    public var id: Int?
    public var email: String
    public var name: String
    public var password: String
    public var passwordChangeCount: Int

    public static let createdAtKey = \JWTKeychainUser.createdAt
    public static let updatedAtKey = \JWTKeychainUser.updatedAt
    public static let deletedAtKey = \JWTKeychainUser.deletedAt

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
extension JWTKeychainUser: Migration {}
extension JWTKeychainUser: MySQLModel {}
extension JWTKeychainUser: Parameter {}
