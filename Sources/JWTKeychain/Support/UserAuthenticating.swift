import Fluent
import SMTP
import Vapor

public protocol UserAuthenticating: EmailAddressRepresentable, JSONRepresentable, NodeRepresentable, TokenCreating {
    static func findByEmail(request: Request) throws -> Self
    static func findById(request: Request) throws -> Self
    static func logIn(request: Request) throws -> Self
    static func logOut(request: Request) throws -> Self
    static func makeUser(request: Request, hasher: HashProtocol) throws -> Self
    static func update(request: Request, hasher: HashProtocol) throws -> Self
}

extension UserAuthenticating where Self: Entity {
    public static func findById(request: Request) throws -> Self {
        let id: Identifier

        do {
            id = try request.data.get(idKey)
        } catch {
            throw Abort(.preconditionFailed, reason: "\"id\" is required")
        }

        guard let user = try find(id) else {
            throw Abort.notFound
        }

        return user
    }

    public static func logIn(request: Request) throws -> Self {
        return try findById(request: request)
    }

    public static func logOut(request: Request) throws -> Self {
        return try findById(request: request)
    }
}

