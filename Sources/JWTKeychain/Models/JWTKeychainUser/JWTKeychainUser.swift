import Fluent
import Vapor

/// Basic implementation for a JWTKeychain compatible user.
public final class JWTKeychainUser: Content, Model {

    public static let schema = "keychain_user"

    @ID(key: "id")
    public var id: Int?

    @Field(key: "email")
    public var email: String

    @Field(key: "name")
    public var name: String

    @Field(key: "password")
    public var password: String

    @Field(key: "password_change_count")
    public var passwordChangeCount: Int

    @Field(key: "created_at")
    public var createdAt: Date?

    @Field(key: "updated_at")
    public var updatedAt: Date?

    @Field(key: "deleted_at")
    public var deletedAt: Date?

    public init() {}
    
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
