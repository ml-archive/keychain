import Sugar

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
