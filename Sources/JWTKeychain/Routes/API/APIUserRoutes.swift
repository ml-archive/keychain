import Authentication
import HTTP
import JWT
import Routing
import Vapor

/// Defines basic user authorization routes.
internal struct APIUserRoutes: RouteCollection {
    public typealias Wrapped = Responder
    
    private let apiAccessMiddleware: Middleware
    private let refreshMiddleware: Middleware?
    private let commonMiddleware: [Middleware]
    private let controller: APIUserController
    private let pathPrefix: String

    /// Initializes the user route collection.
    ///
    /// - Parameters:
    ///   - apiAccessMiddleware: authentication middleware for API access.
    ///   - refreshMiddleware: optional authentication middleware for refresh
    ///     token endpoint.
    ///   - userController: controller for handling user routes.
    internal init(
        apiAccessMiddleware: Middleware,
        refreshMiddleware: Middleware?,
        commonMiddleware: [Middleware],
        controller: APIUserController,
        pathPrefix: String
    ) {
        self.apiAccessMiddleware = apiAccessMiddleware
        self.refreshMiddleware = refreshMiddleware
        self.commonMiddleware = commonMiddleware
        self.controller = controller
        self.pathPrefix = pathPrefix
    }

    internal func build(
        _ builder: RouteBuilder
    ) throws {
        
        // Get the base path group
        let path = builder
            .grouped(commonMiddleware)
            .grouped(pathPrefix, "users")
        
        // Auth routes
        path.post(handler: controller.register)
        path.post("login", handler: controller.logIn)
        path.post("reset-password", "request",
            handler: controller.resetPasswordEmail
        )

        // Protected routes
        path.group(apiAccessMiddleware) { apiAccess in
            apiAccess.get("logout", handler: controller.logOut)
            apiAccess.get("me", handler: controller.me)
            apiAccess.patch("update", handler: controller.update)
        }

        // Refresh access token
        let refreshMiddleware = self.refreshMiddleware ?? apiAccessMiddleware
        path.group(refreshMiddleware) { refresh in
            refresh.patch(
                "token",
                "regenerate",
                handler: controller.regenerate
            )
        }
    }
}
