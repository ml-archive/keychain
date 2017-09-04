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

extension JWTKeychainAuthenticatable where Self: EmailAddressRepresentable & PasswordAuthenticatable & Entity {

    /// Find user by U.usernameKey (e.g. "email") and fetches from database.
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

public protocol P {
    static var passwordHasher: HashProtocol { get }
    init(email: Valid<UniqueEmail>, name: Valid<Name>?, password: HashedPassword) throws
    func update(email: Valid<UniqueEmail>?, name: Valid<Name>?, password: HashedPassword?) throws
}

extension JWTKeychainAuthenticatable where Self: EmailAddressRepresentable & PasswordAuthenticatable & Entity & P {

    /// Creates a new user from the values in the request.
    /// - Parameters:
    ///   - request: request with values for the keys U.usernameKey (e.g.
    ///     "email"), U.passwordKey and optionally "name".
    /// - Throws: Abort error when email and/or password are missing or a
    ///   ValidationError if any of the input is invalid
    /// - Returns: the new user
    public static func make(request: Request) throws -> Self {
        let creds = try getCredentials(from: request)

        let name = request.data[usernameKey]?.string

        let user = try Self(
            email: Valid(creds.username),
            name: name.map(Valid.init),
            password: passwordHasher.hash(Valid(creds.password))
        )

        return user
    }

    /// Updates an existing user with the values from the request.
    /// - Parameters:
    ///   - request: request that optionally contains values for the keys
    ///     U.usernameKey (e.g. "email), "name", and both "password" +
    ///     "newPassword" in case of a password change.
    /// - Throws: when password does not match or user could not be saved
    /// - Returns: the updated user
    public static func update(request: Request) throws -> Self {
        let data = request.data
        let user: Self = try request.auth.assertAuthenticated()

        let password: String?
        if
            let newPassword = data["newPassword"]?.string,
            let oldPassword = data[passwordKey]?.string,
            let hashedPassword = user.hashedPassword,
            let verified = try passwordVerifier?.verify(
                password: oldPassword,
                matches: hashedPassword
            ),
            verified,
            newPassword != oldPassword {

            password = newPassword
        } else {
            password = nil
        }

        let username = data[usernameKey]?.string
        let name = data[usernameKey]?.string

        try user.update(
            email: username.map(Valid.init),
            name: name.map(Valid.init),
            password: password.map(Valid.init).map(passwordHasher.hash)
        )

        try user.save()

        return user
    }
}
