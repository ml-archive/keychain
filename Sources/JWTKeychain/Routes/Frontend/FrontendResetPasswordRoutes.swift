import Authentication
import Flash
import Forms
import HTTP
import Routing
import Vapor

/// Defines basic reset password routes.
internal struct FrontendResetPasswordRoutes: RouteCollection {
    internal typealias Wrapped = Responder
    
    private let controller: FrontendUserController

    /// Initializes the user route collection.
    ///
    /// - parameters resetPasswordController: controller for handling user reset
    ///   password routes.
    internal init(
        controller: FrontendUserController
    ) {
        self.controller = controller
    }
    
    internal func build(
        _ builder: RouteBuilder
    ) throws {

        // Get the base path group
        let path = builder.grouped("users", "reset-password")

        path.group(FlashMiddleware(), FieldSetMiddleware()) { routes in
            routes.get(
                "form",
                String.parameter,
                handler: controller.resetPasswordForm
            )
            routes.post(
                "change",
                String.parameter,
                handler: controller.resetPasswordChange
            )
        }
    }
}
