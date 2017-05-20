import Fluent
import Vapor

public protocol HasEmail: Entity {
    var email: String { get }
}

extension UserAuthenticating where Self: HasEmail {
    public static func findByEmail(request: Request) throws -> Self {
        let email: String
        
        do {
            email = try request.data.get(User.Keys.email)
        } catch {
            throw Abort(.preconditionFailed, reason: "Email is required")
        }

        guard let user = try Self.makeQuery().filter(User.Keys.email, email).first() else {
            throw Abort.badRequest
        }

        return user
    }
}
