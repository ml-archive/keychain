import Vapor
import Auth
import Routing
import HTTP

/// Defines basic reset password routes.
public struct FrontendResetPasswordRoutes: RouteCollection {
    public typealias Wrapped = Responder

    private let drop: Droplet
    private let configuration: ConfigurationType!
    private let controller: FrontendResetPasswordControllerType!

    /// Initializes the user route collection.
    ///
    /// - Parameters:
    ///   - drop: the droplet reference.
    ///   - configuration: configuration for JWT.
    ///     Defaults to `Configuration`.
    ///   - jwtAuthMiddleware: middleware for JWT authentication.
    ///     Defaults to `JWT.AuthMiddleware`.
    ///   - authMiddleware: authentication middleware.
    ///     Defaults to `Auth.AuthMiddleware`.
    ///   - protectMiddleware: protect middleware for protected routes.
    ///     Defaults to `ProtectMiddleware`.
    ///   - userController: controller for handling user routes.
    ///     Defaults to `UserController`.
    /// - Throws: if configuration cannot be created.
    public init(
        drop: Droplet,
        configuration: ConfigurationType? = nil,
        resetPasswordController: FrontendResetPasswordControllerType? = nil
        ) throws {

        self.drop = drop
        let config = try configuration ?? Configuration(drop: drop)
        self.configuration = config
        self.controller = resetPasswordController ?? FrontendResetPasswordController(drop: drop, configuration: config)

    }

    public func build<Builder: RouteBuilder>(
        _ builder: Builder
        ) where Builder.Value == Responder {

        // Get the base path group
        builder.group("reset-password") { routes in
            routes.get("form", String.self, handler: controller.resetPasswordForm)
            routes.post("change", handler: controller.resetPasswordChange)
        }

    }
}
