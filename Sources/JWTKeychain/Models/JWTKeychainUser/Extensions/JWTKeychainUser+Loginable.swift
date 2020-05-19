import Vapor

extension JWTKeychainUser {
    public struct Login: Content {
        public static let readablePasswordKey = \Login.password
        public static let readableUsernameKey = \Login.email

        let email: String
        let password: String
    }
}
