import Authentication
import Fluent
import SMTP
import Vapor
import protocol JWT.Storable

public protocol UserAuthenticating {
    associatedtype U: PasswordAuthenticatable, EmailAddressRepresentable,
        Entity, JSONRepresentable, NodeRepresentable

    func find(request: Request) throws -> U
    func logIn(request: Request) throws -> U
    func logOut(request: Request) throws -> U
    func make(request: Request) throws -> U
    func update(request: Request) throws -> U
}

extension UserAuthenticating {

    /// Find user by U.usernameKey (e.g. "email") and fetches from database.
    /// - Parameter request: request that should contain a value for the key
    ///   equal to U.usernameKey
    /// - Throws: Abort error when usernameKey key is not present, or user could
    ///   not be found
    public func find(request: Request) throws -> U {
        let email: String

        do {
            email = try request.data.get(U.usernameKey)
        } catch {
            throw Abort(
                .preconditionFailed,
                reason: "The field \"\(U.usernameKey)\" is required"
            )
        }

        guard let user = try U.makeQuery().filter(U.usernameKey, email).first()
            else {
                throw Abort.notFound
        }

        return user
    }

    public func logIn(request: Request) throws -> U {
        let credentials = try getCredentials(from: request)
        return try U.authenticate(credentials)
    }

    public func logOut(request: Request) throws -> U {
        let user: U = try request.auth.assertAuthenticated()

        try request.auth.unauthenticate()

        return user
    }

    fileprivate func getCredentials(
        from request: Request
    ) throws -> Authentication.Password {
        let data = request.data

        guard
            let password = data[U.passwordKey]?.string,
            let username = data[U.usernameKey]?.string else {
                throw Abort.unauthorized
        }

        return Authentication.Password(username: username, password: password)
    }
}

public class UserAuthenticator: UserAuthenticating {
    public typealias U = User

    public init() {}

    /// Creates a new user from the values in the request.
    /// - Parameters:
    ///   - request: request with values for the keys U.usernameKey (e.g.
    ///     "email"), U.passwordKey and optionally "name".
    /// - Throws: Abort error when email and/or password are missing or a
    ///   ValidationError if any of the input is invalid
    /// - Returns: the new user
    public func make(request: Request) throws -> U {
        let creds = try getCredentials(from: request)

        let name = request.data[U.Keys.name]?.string

        let user = try U(
            email: Valid(creds.username),
            name: name.map(Valid.init),
            password: U.passwordHasher.hash(Valid(creds.password))
        )

        try user.save()

        return user
    }

    /// Updates an existing user with the values from the request.
    /// - Parameters:
    ///   - request: request that optionally contains values for the keys
    ///     U.usernameKey (e.g. "email), "name", and both "password" +
    ///     "newPassword" in case of a password change.
    /// - Throws: when password does not match or user could not be saved
    /// - Returns: the updated user
    public func update(request: Request) throws -> U {
        let data = request.data
        let user: U = try request.auth.assertAuthenticated()

        let password: String?
        if
            let newPassword = data["newPassword"]?.string,
            let oldPassword = data[U.passwordKey]?.string,
            let hashedPassword = user.hashedPassword,
            let verified = try U.passwordVerifier?.verify(
                password: oldPassword,
                matches: hashedPassword
            ),
            verified,
            newPassword != oldPassword {

            password = newPassword
        } else {
            password = nil
        }

        let username = data[U.usernameKey]?.string
        let name = data[U.Keys.name]?.string

        try user.update(
            email: username.map(Valid.init),
            name: name.map(Valid.init),
            password: password.map(Valid.init).map(U.passwordHasher.hash)
        )

        try user.save()

        return user
    }
}
