import Vapor

extension Storage {
    subscript<Key>(
        _ key: Key.Type,
        orSetDefault default: @autoclosure () -> Key.Value
    ) -> Key.Value where Key: StorageKey {
        mutating get {
            guard let value = self[Key.self] else {
                let value = `default`()
                self[Key.self] = value
                return value
            }
            return value
        }
    }
}
