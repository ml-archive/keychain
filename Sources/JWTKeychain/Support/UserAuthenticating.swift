import Fluent
import SMTP
import Vapor

public protocol UserAuthenticating {
    associatedtype U: EmailAddressRepresentable, JSONRepresentable, NodeRepresentable, TokenCreating

    func findByEmail(request: Request) throws -> U
    func findById(request: Request) throws -> U
    func logIn(request: Request) throws -> U
    func logOut(request: Request) throws -> U
    func makeUser(request: Request, hasher: HashProtocol) throws -> U
    func update(request: Request, hasher: HashProtocol) throws -> U
}

public class UserAuthenticator: UserAuthenticating {
    public typealias U = User

    /// Creates a new user from the values in the request. Hashes password using the hasher.
    /// - Parameters:
    ///   - request: request with values for the keys "email", "password" and optionally "name".
    ///   - hasher: the hasher with which to hash the raw password value from the request
    /// - Throws: Abort error when email and/or password are missing or a ValidationError if any of the input is invalid
    /// - Returns: the new user
    public func makeUser(request: Request, hasher: HashProtocol) throws -> U {
        let data = request.data

        guard
            let email = data[User.Keys.email]?.string,
            let password = data[User.Keys.password]?.string else {
                throw Abort(.preconditionFailed, reason: "The fields \"email\" and/or \"password\" are missing")
        }

        let name = data[User.Keys.name]?.string

        return try User(
            email: Valid(email),
            name: name.map(Valid.init),
            password: hasher.hash(Valid(password))
        )
    }

    /// Updates an existing user with the values from the request. Hashes password using the hasher in case of a
    /// password change.
    /// - Parameters:
    ///   - request: request that optionally contains values for the keys "email", "name", and both "password" +
    ///              "new_password" in case of a password change.
    ///   - hasher: the hasher with which to hash the raw password value from the request
    /// - Throws: when the password does not match or the user could not be saved
    /// - Returns: the updated user
    public func update(request: Request, hasher: HashProtocol) throws -> U {
        let data = request.data
        let user = try findById(request: request)

        let password: String?
        if
            let newPassword = data["new_password"]?.string,
            let oldPassword = data[User.Keys.password]?.string,
            try hasher.check(oldPassword, matchesHash: user.password),
            newPassword != oldPassword {

            password = newPassword
        } else {
            password = nil
        }

        let name = data[User.Keys.name]?.string
        let email = data[User.Keys.email]?.string

        return try user.update(
            email: email.map(Valid.init),
            name: name.map(Valid.init),
            password: password.map(Valid.init).map(hasher.hash)
        )
    }
}

extension UserAuthenticating where U: Entity {
    public func findById(request: Request) throws -> U {
        let id: Identifier

        do {
            id = try request.data.get(U.idKey)
        } catch {
            throw Abort(.preconditionFailed, reason: "\"id\" is required")
        }

        guard let user = try U.find(id) else {
            throw Abort.notFound
        }

        return user
    }

    public func logIn(request: Request) throws -> U {
        return try findById(request: request)
    }

    public func logOut(request: Request) throws -> U {
        return try findById(request: request)
    }
}

extension UserAuthenticating where U: HasEmail {
    public func findByEmail(request: Request) throws -> U {
        let email: String

        do {
            email = try request.data.get(User.Keys.email)
        } catch {
            throw Abort(.preconditionFailed, reason: "Email is required")
        }

        guard let user = try U.makeQuery().filter(User.Keys.email, email).first() else {
            throw Abort.notFound
        }

        return user
    }
}