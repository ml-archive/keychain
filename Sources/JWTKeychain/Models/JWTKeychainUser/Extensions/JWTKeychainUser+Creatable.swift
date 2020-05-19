import Vapor

extension JWTKeychainUser {
    public struct Create: Content {
        public static let readablePasswordKey = \Create.password
        public static let readableUsernameKey = \Create.email

        let email: String
        let name: String
        let password: String
    }

    public convenience init(_ create: Create) throws {
        try self.init(
            email: create.email,
            name: create.name,
            password: Bcrypt.hash(create.password, cost: 10)
        )
    }
}
