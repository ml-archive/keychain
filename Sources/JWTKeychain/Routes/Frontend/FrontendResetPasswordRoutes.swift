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
    ///   - drop: the droplet reference.
    ///   - configuration: configuration for JWT.
    ///     Defaults to `Configuration`.
    ///   - resetPasswordController: controller for handling user reset password
    ///     routes.
    ///     Defaults to `FrontendResetPasswordControllerType`.
    public init(
        resetPasswordController: FrontendResetPasswordControllerType
    ) {
        self.controller = resetPasswordController
    }
    
    public func build(
        _ builder: RouteBuilder
    ) throws {

        // Get the base path group
        let path = builder.grouped("users")

        path.group(FlashMiddleware()) { routes in
            // Get the base path group
            routes.group("reset-password") { routes in
                routes.get("form", String.parameter, handler: controller.resetPasswordForm)
                routes.post("change", handler: controller.resetPasswordChange)
            }
        }
    }
}
