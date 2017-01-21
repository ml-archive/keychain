import Vapor
import Auth
import Routing
import HTTP

/// Defines basic user authorization routes.
public struct UserRoutes: RouteCollection {
    public typealias Wrapped = Responder

    private let drop: Droplet
    private let authMiddleware: Middleware
    private let jwtAuthMiddleware: JWTKeychain.AuthMiddleware!
    private let protectMiddleware: ProtectMiddleware
    private let configuration: ConfigurationType!
    private let controller: UserControllerType!


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
        jwtAuthMiddleware: AuthMiddleware? = nil,
        authMiddleware: Middleware = Auth.AuthMiddleware<User>(),
        protectMiddleware: ProtectMiddleware = ProtectMiddleware(
            error: Abort.custom(
                status: .unauthorized,
                message: Status.unauthorized.reasonPhrase
            )
        ),
        userController: UserControllerType? = nil
    ) throws {
        self.drop = drop
        let config = try configuration ?? Configuration(drop: drop)
        self.configuration = config
        self.jwtAuthMiddleware = jwtAuthMiddleware ?? JWTKeychain.AuthMiddleware(configuration: config)
        self.authMiddleware = authMiddleware
        self.protectMiddleware = protectMiddleware
        self.controller = userController ?? UserController(configuration: config, drop: drop)
    }

    public func build<Builder: RouteBuilder>(
        _ builder: Builder
    ) where Builder.Value == Responder {

        // Get the base path group
        let path = builder.grouped("users")

        // Auth routes
        path.group(authMiddleware) { jwtRoutes in
            jwtRoutes.post(handler: controller.register)
            jwtRoutes.post("login", handler: controller.login)
            jwtRoutes.post("reset-password", "request", handler: controller.resetPasswordEmail)
            jwtRoutes.get("reset-password", "form", String.self, handler: controller.resetPasswordForm)
            jwtRoutes.post("reset-password", "change", handler: controller.resetPasswordChange)
        }

        // Protected routes
        path.group(authMiddleware, jwtAuthMiddleware,  protectMiddleware) { secured in
            secured.get("logout", handler: controller.logout)
            secured.patch("token", "regenerate", handler: controller.regenerate)
            secured.get("me", handler: controller.me)
        }
    }
}
