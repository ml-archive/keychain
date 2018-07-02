import Sugar
import Vapor

extension JWTKeychainUser: JWTKeychainUserType {
    public static let passwordKey: WritableKeyPath<JWTKeychainUser, String> = \.password
    public static let usernameKey: WritableKeyPath<JWTKeychainUser, String> = \.email

    public struct Registration: HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \Registration.password
        public static let readableUsernameKey = \Registration.email

        let email: String
        let name: String
        let password: String
    }

    public struct Login: HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \Login.password
        public static let readableUsernameKey = \Login.email

        let email: String
        let password: String
    }

    public struct Public: Content {
        let email: String
        let name: String
    }

    public struct Update: Decodable {
        let name: String?
    }

    public convenience init(_ registration: Registration) throws {
        try self.init(
            email: registration.email,
            name: registration.name,
            password: JWTKeychainUser.hashPassword(registration.password)
        )
    }

    public func update(with update: Update) throws {
        if let name = update.name {
            self.name = name
        }
    }

    public func convertToPublic(on req: Request) throws -> Future<Public> {
        return req.future(.init(email: email, name: name))
    }
}
