import Vapor

extension JWTKeychainUser {
    public struct Update: Content {
        let name: String?
    }

    public func update(_ update: Update) throws {
        if let name = update.name {
            self.name = name
        }
    }
}
