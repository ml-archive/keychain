import Foundation
import Vapor

/// Controller for user API requests
final internal class APIUserController {
    private let delegate: APIUserControllerDelegateType
    private let passwordResetMailer: PasswordResetMailerType
    private let tokenGenerators: TokenGenerators

    init(
        delegate: APIUserControllerDelegateType,
        passwordResetMailer: PasswordResetMailerType,
        tokenGenerators: TokenGenerators
    ) {
        self.delegate = delegate
        self.passwordResetMailer = passwordResetMailer
        self.tokenGenerators = tokenGenerators
    }

    /// Registers a user and created an instance in the database.
    ///
    /// - parameter request: current request.
    /// - Returns: JSON response with User data.
    internal func register(request: Request) throws -> ResponseRepresentable {
        return try delegate.register(
            request: request,
            tokenGenerators: tokenGenerators
        )
    }

    /// Logs the user in to the system, giving the token back.
    ///
    /// - parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on invalid data or wrong credentials.
    internal func logIn(request: Request) throws -> ResponseRepresentable {
        return try delegate.logIn(
            request: request,
            tokenGenerators: tokenGenerators
        )
    }

    /// Logs the user out of the system.
    ///
    /// - parameter request: current request.
    /// - Returns: JSON success response.
    /// - Throws: if not able to find token.
    internal func logOut(request: Request) throws -> ResponseRepresentable {
        return try delegate.logOut(
            request: request,
            tokenGenerators: tokenGenerators
        )
    }

    /// Generates a new token for the user.
    ///
    /// - parameter request: current request.
    /// - Returns: JSON with token.
    /// - Throws: if not able to generate token.
    internal func regenerate(request: Request) throws -> ResponseRepresentable {
        return try delegate.regenerate(
            request: request,
            tokenGenerators: tokenGenerators
        )
    }

    /// Returns the authenticated user data.
    ///
    /// - parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on no user found.
    internal func me(request: Request) throws -> ResponseRepresentable {
        return try delegate.me(
            request: request,
            tokenGenerators: tokenGenerators
        )
    }

    /// Requests a reset of password for the given email.
    ///
    /// - parameter request: current request.
    /// - Returns: success or failure message
    internal func resetPasswordEmail(
        request: Request
    ) throws -> ResponseRepresentable {
        return try delegate.resetPasswordEmail(
            request: request,
            tokenGenerators: tokenGenerators,
            passwordResetMailer: passwordResetMailer
        )
    }

    /// Update a user's info (including password)
    ///
    /// - parameter request: current request.
    /// - Returns: success or failure message
    func update(request: Request) throws -> ResponseRepresentable {
        return try delegate.update(
            request: request,
            tokenGenerators: tokenGenerators
        )
    }
}
