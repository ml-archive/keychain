import Authentication
import HTTP
import Routing
import Vapor

/// Defines basic reset password routes.
internal struct FrontendResetPasswordRoutes: RouteCollection {
    internal typealias Wrapped = Responder
    
    private let controller: FrontendUserController
    private let middleware: [Middleware]
    private let pathPrefix: String

    /// Initializes the user route collection.
    ///
    /// - parameters
    ///   - controller: controller for handling user reset password routes.
    ///   - middleware: middleware to add to all routes
    ///   - pathPrefix: path to prefix before all routes
    internal init(
        controller: FrontendUserController,
        middleware: [Middleware],
        pathPrefix: String
    ) {
        self.controller = controller
        self.middleware = middleware
        self.pathPrefix = pathPrefix
    }
    
    internal func build(
        _ builder: RouteBuilder
    ) throws {

        // Get the base path group
        let path = builder
            .grouped(middleware)
            .grouped(pathPrefix, "users", "reset-password")

        path.get(
            "form",
            String.parameter,
            handler: controller.resetPasswordForm
        )
        path.post(
            "change",
            String.parameter,
            handler: controller.resetPasswordChange
        )
    }
}
