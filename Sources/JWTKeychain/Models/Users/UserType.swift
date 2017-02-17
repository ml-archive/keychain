import Auth
import Vapor
import Sugar
import Foundation
import VaporForms

/// Defines minimum requirements for setting up a user than can be authorized.
public protocol UserType: Auth.User, NodesModel {
    /// The type of validator to be initialized on model instantiation.
    associatedtype Validator: Form
    
    /// Name of user.
    var name: String? { get set }
    /// Email of user.
    var email: String { get set }
    /// Password for user.
    var password: String { get set }
    
    init(validated: Validator)
    
    /// Creates JSON.
    ///
    /// - Parameter token: Token to include in payload.
    /// - Returns: User in JSON format.
    /// - Throws: On transformation issue.
    func makeJSON(token: String) throws -> JSON

    /// Creates a Node specifically for the 
    /// JWT token
    ///
    /// - Returns: Node
    /// - Throws: cannot create Node
    func makeJWTNode() throws -> Node
}


// MARK: - Default implementations
extension UserType {
    public func makeJSON(token: String) throws -> JSON {
        return try JSON(node: [
            "id": self.id,
            "name": self.name,
            "email": self.email,
            "token": token,
            "created_at": self.createdAt?.to(Date.Format.ISO8601),
            "updated_at": self.updatedAt?.to(Date.Format.ISO8601),
            "deleted_at": self.deletedAt?.to(Date.Format.ISO8601),
        ])
    }
    
    public func makeJWTNode() throws -> Node {
        return try Node(node: [
            "id": self.id,
            "email": self.email,
            "password": self.password,
        ])
    }
}
