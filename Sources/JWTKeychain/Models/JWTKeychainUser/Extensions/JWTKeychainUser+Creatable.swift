import Sugar

extension JWTKeychainUser: Creatable {
    public struct Create: Decodable, HasReadablePassword, HasReadableUsername {
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
            password: JWTKeychainUser.hashPassword(create.password)
        )
    }
}
