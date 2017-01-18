import Auth
import Vapor
import Foundation

/// Defines minimum requirements for setting up a user than can be authorized.
public protocol UserType: Auth.User {
    var id: Node? { get }

    /// Name of user.
    var name: String! { get }
    /// Email of user.
    var email: String! { get }
    /// Password for user.
    var password: String! { get }

    /// Created at time stamp.
    var createdAt: Date? { get }
    /// Updated at time stamp.
    var updatedAt: Date? { get }
    /// Deleted at time stamp.
    var deletedAt: Date? { get }

    /// Creates JSON.
    ///
    /// - Parameter token: Token to include in payload.
    /// - Returns: User in JSON format.
    /// - Throws: On transformation issue.
    func makeJSON(token: String) throws -> JSON
}
