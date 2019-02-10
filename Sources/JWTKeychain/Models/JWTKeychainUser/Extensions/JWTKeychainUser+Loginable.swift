import Sugar

extension JWTKeychainUser: Loginable {
    public struct Login: Decodable, HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \Login.password
        public static let readableUsernameKey = \Login.email

        let email: String
        let password: String
    }
}
