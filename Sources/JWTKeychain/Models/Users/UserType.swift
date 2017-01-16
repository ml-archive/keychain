import Auth
import Vapor
import Foundation

/// Defines minimum requirements for setting up a user than can be authorized.
public protocol UserType: Auth.User {
    var id: Node? { get }

    var name: String! { get }
    var email: String! { get }
    var password: String! { get }

    var createdAt: Date? { get }
    var updatedAt: Date? { get }
    var deletedAt: Date? { get }
}
