import Fluent
import Vapor

public protocol HasEmail: Entity {
    var email: String { get }
}

extension UserAuthenticating where Self: HasEmail {

    /// Find user by email and fetches from database.
    /// - Parameter request: request that should contain a value for the key "email"
    /// - Throws: Abort error when "email" key is not present, or user could not be found 
    public static func findByEmail(request: Request) throws -> Self {
        let email: String
        
        do {
            email = try request.data.get(User.Keys.email)
        } catch {
            throw Abort(.preconditionFailed, reason: "Email is required")
        }

        guard let user = try Self.makeQuery().filter(User.Keys.email, email).first() else {
            throw Abort.notFound
        }

        return user
    }
}
