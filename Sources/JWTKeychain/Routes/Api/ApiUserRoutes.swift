import Authentication
import HTTP
import JWT
import Routing
import Vapor

/// Defines basic user authorization routes.
public struct ApiUserRoutes: RouteCollection {
    public typealias Wrapped = Responder
    
    private let authMiddleware: Middleware
    private let controller: UserControllerType

    /// Initializes the user route collection.
    ///
    /// - Parameters:
    ///   - authMiddleware: authentication middleware.
    ///   - userController: controller for handling user routes.
    /// - Throws: if configuration cannot be created.
    public init(
        authMiddleware: Middleware,
        userController: UserControllerType
    ) {
        self.authMiddleware = authMiddleware
        self.controller = userController
    }

    public func build(
        _ builder: RouteBuilder
    ) throws {
        // Get the base path group
        let path = builder.grouped("users")
        
        // Auth routes
        path.post(handler: controller.register)
        path.post("login", handler: controller.logIn)
        path.post("reset-password", "request", handler: controller.resetPasswordEmail)

        // Protected routes
        path.group(authMiddleware) { secured in
            secured.get("logout", handler: controller.logOut)
            secured.get("me", handler: controller.me)
            secured.patch("token", "regenerate", handler: controller.regenerate)
            secured.patch("update", handler: controller.update)
        }
    }
}
