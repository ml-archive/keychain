import Authentication
import Flash
import HTTP
import Routing
import Vapor

/// Defines basic reset password routes.
public struct FrontendResetPasswordRoutes: RouteCollection {
    public typealias Wrapped = Responder
    
    private let controller: FrontendResetPasswordControllerType!

    /// Initializes the user route collection.
    ///
    /// - Parameters:
    ///   - resetPasswordController: controller for handling user reset password
    ///     routes.
    public init(
        resetPasswordController: FrontendResetPasswordControllerType
    ) {
        self.controller = resetPasswordController
    }
    
    public func build(
        _ builder: RouteBuilder
    ) throws {

        // Get the base path group
        let path = builder.grouped("users", "reset-password")

        path.group(FlashMiddleware()) { routes in
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
