import Sugar
import Vapor

extension JWTKeychainUser: JWTKeychainUserType {
    public static let passwordKey: WritableKeyPath<JWTKeychainUser, String> = \.password
    public static let usernameKey: WritableKeyPath<JWTKeychainUser, String> = \.email

    public struct Login: Decodable, HasReadablePassword, HasReadableUsername {
        public static let readablePasswordKey = \Login.password
        public static let readableUsernameKey = \Login.email

        let email: String
        let password: String
    }

    public struct Public: Content {
        let email: String
        let name: String
    }

    public func convertToPublic(on req: Request) throws -> Future<Public> {
        return req.future(.init(email: email, name: name))
    }
}

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

extension JWTKeychainUser: Updatable {
    public struct Update: Decodable {
        let name: String?
    }

    public func update(_ update: Update) throws {
        if let name = update.name {
            self.name = name
        }
    }
}
