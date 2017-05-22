import Vapor
import HTTP

// TODO: update header docs
/// Defines basic authorization functionality.
public protocol UserControllerType {

    /// Registers a user on the DB.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on invalid data or if unable to store data on the DB.
    func register(request: Request) throws -> ResponseRepresentable

    /// Logs the user in to the system, giving the token back.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on invalid data or wrong credentials.
    func logIn(request: Request) throws -> ResponseRepresentable

    /// Logs the user out of the system.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON success response.
    /// - Throws: if not able to find token.
    func logOut(request: Request) throws -> ResponseRepresentable

    /// Generates a new token for the user.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON with token.
    /// - Throws: if not able to generate token.
    func regenerate(request: Request) throws -> ResponseRepresentable

    /// Returns the authenticated user data.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on no user found.
    func me(request: Request) throws -> ResponseRepresentable

    /// Requests a reset of password for the given email.
    ///
    /// - Parameter request: current request.
    /// - Returns: success or failure message
    func resetPasswordEmail(request: Request) throws -> ResponseRepresentable

    /// Update a user's info (including password)
    ///
    /// - Parameter request: current request.
    /// - Returns: success or failure message
    func update(request: Request) throws -> ResponseRepresentable
}
