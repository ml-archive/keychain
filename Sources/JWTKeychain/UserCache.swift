import Vapor

final class UserCache<U: JWTKeychainUser>: Service {
    private var cachedUser: Future<U>?
    func user(on request: Request) throws -> Future<U> {
        if let cachedUser = cachedUser {
            return cachedUser
        } else {
            let user = try U.load(on: request)
            cachedUser = user
            return user
        }
    }
}
