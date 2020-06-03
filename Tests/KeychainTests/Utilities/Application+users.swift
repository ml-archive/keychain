import Vapor

extension Application {
    final class Users {
        fileprivate struct Key: StorageKey {
            typealias Value = Users
        }

        var testUser: User?
    }

    var users: Users {
        guard let value = storage[Users.Key.self] else {
            let value = Users()
            storage[Users.Key.self] = value
            return value
        }
        return value
    }
}
