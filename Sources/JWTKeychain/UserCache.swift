import Vapor

final class PayloadCache<P: JWTKeychainPayload>: Service {
    var payload: P? = nil
}

final class UserCache<U>: Service {
    private let loadUser: UserLoader<U>

    init(loadUser: @escaping UserLoader<U>) {
        self.loadUser = loadUser
    }

    private var cachedUser: Future<U>?
    func user(on request: Request) throws -> Future<U> {
        if let cachedUser = cachedUser {
            return cachedUser
        } else {
            let user = try loadUser(request)
            cachedUser = user
            return user
        }
    }
}
