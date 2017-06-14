import Authentication
import HTTP
import JWT
import Routing
import Vapor

/// Defines basic user authorization routes.
public struct ApiUserRoutes: RouteCollection {
    public typealias Wrapped = Responder
    
    private let apiAccessMiddleware: Middleware
    private let refreshMiddleware: Middleware
    private let controller: UserControllerType

    /// Initializes the user route collection.
    ///
    /// - Parameters:
    ///   - authMiddleware: authentication middleware.
    ///   - userController: controller for handling user routes.
    /// - Throws: if configuration cannot be created.
    public init(
        apiAccessMiddleware: Middleware,
        refreshMiddleware: Middleware,
        userController: UserControllerType
    ) {
        self.apiAccessMiddleware = apiAccessMiddleware
        self.refreshMiddleware = refreshMiddleware
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
        path.group(apiAccessMiddleware) { apiAccess in
            apiAccess.get("logout", handler: controller.logOut)
            apiAccess.get("me", handler: controller.me)
            apiAccess.patch("update", handler: controller.update)
        }

        // Refresh access token
        path.group(refreshMiddleware) { refresh in
            refresh.patch("token", "regenerate", handler: controller.regenerate)
        }
    }
}
