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
    private let mailer: MailerType
  
    /// Initializes the user route collection.
    ///
    /// - Parameters:
    ///   - drop: the droplet reference.
    ///   - authMiddleware: authentication middleware.
    ///   - userController: controller for handling user routes.
    /// - Throws: if configuration cannot be created.
    public init(
        authMiddleware: Middleware,
        mailer: MailerType,
        userController: UserControllerType
    ) throws {
        self.authMiddleware = authMiddleware
        self.mailer = mailer
        self.controller = userController
    }

    public func build(
        _ builder: RouteBuilder
    ) throws {
        // Get the base path group
        let path = builder.grouped("users")
        
        // Auth routes
        path.post(handler: controller.register)
        path.post("login", handler: controller.login)
        path.post("reset-password", "request", handler: controller.resetPasswordEmail)

        // Protected routes
        path.group(authMiddleware) { secured in
            secured.get("logout", handler: controller.logout)
            secured.patch("token", "regenerate", handler: controller.regenerate)
            secured.get("me", handler: controller.me)
        }
    }
}
