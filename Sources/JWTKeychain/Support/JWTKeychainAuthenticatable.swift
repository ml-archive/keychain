import Authentication
import Fluent
import SMTP
import Vapor
import protocol JWT.Storable

public protocol JWTKeychainAuthenticatable {
    static func find(request: Request) throws -> Self
    static func logIn(request: Request) throws -> Self
    static func logOut(request: Request) throws -> Self
    static func make(request: Request) throws -> Self
    static func update(request: Request) throws -> Self
}

extension JWTKeychainAuthenticatable where Self:
    EmailAddressRepresentable & PasswordAuthenticatable & Entity {

    /// Find user by U.usernameKey (e.g. "email") and fetches from database.
    ///
    /// - Parameter request: request that should contain a value for the key
    ///   equal to U.usernameKey
    /// - Throws: Abort error when usernameKey key is not present, or user could
    ///   not be found
    public static func find(request: Request) throws -> Self {
        let email: String

        do {
            email = try request.data.get(usernameKey)
        } catch {
            throw Abort(
                .preconditionFailed,
                reason: "The field \"\(usernameKey)\" is required"
            )
        }

        guard let user = try makeQuery().filter(usernameKey, email).first()
            else {
                throw Abort.notFound
        }

        return user
    }

    public static func logIn(request: Request) throws -> Self {
        let credentials = try getCredentials(from: request)
        return try authenticate(credentials)
    }

    public static func logOut(request: Request) throws -> Self {
        let user: Self = try request.auth.assertAuthenticated()

        try request.auth.unauthenticate()

        return user
    }

    public static func getCredentials(
        from request: Request
    ) throws -> Authentication.Password {
        let data = request.data

        guard
            let password = data[passwordKey]?.string,
            let username = data[usernameKey]?.string else {
                throw Abort.unauthorized
        }

        return Authentication.Password(username: username, password: password)
    }
}

extension JWTKeychainAuthenticatable where Self: RequestInitializable & Entity {
    public static func make(request: Request) throws -> Self {
        let user = try Self(request: request)
        try user.save()
        return user
    }
}

public protocol RequestUpdateable {
    func update(request: Request) throws
}

extension JWTKeychainAuthenticatable where Self:
    RequestUpdateable & Entity & Authenticatable {
    
    public static func update(request: Request) throws -> Self {
        let user: Self = try request.auth.assertAuthenticated()
        try user.update(request: request)
        try user.save()
        return user
    }
}
