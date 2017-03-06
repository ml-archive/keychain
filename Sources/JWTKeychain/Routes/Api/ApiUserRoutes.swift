import Vapor
import Auth
import Routing
import HTTP

/// Defines basic user authorization routes.
public struct ApiUserRoutes<T: UserType>: RouteCollection {
    public typealias Wrapped = Responder
    
    private let drop: Droplet
    private let authMiddleware: Middleware
    private let jwtAuthMiddleware: JWTKeychain.AuthMiddleware!

    private let configuration: ConfigurationType
    private let controller: UserControllerType
    private let mailer: MailerType
  
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
    ///   - userController: controller for handling user routes.
    ///     Defaults to `UserController`.
    /// - Throws: if configuration cannot be created.
    public init(
        drop: Droplet,
        configuration: ConfigurationType? = nil,
        jwtAuthMiddleware: AuthMiddleware? = nil,
        authMiddleware: Middleware = Auth.AuthMiddleware<User>(),
        userController: UserControllerType? = nil,
        mailer: MailerType
    ) throws {
        self.drop = drop
        let config = try configuration ?? Configuration(drop: drop)
        self.configuration = config
        
        self.jwtAuthMiddleware = jwtAuthMiddleware ?? JWTKeychain.AuthMiddleware(
            configuration: config
        )
        self.authMiddleware = authMiddleware
      
        self.mailer = mailer
        
        self.controller = userController ?? BasicUserController(
            configuration: config,
            drop: drop ,
            mailer: mailer
        )
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
        }
        
        // Protected routes
        path.group(authMiddleware, jwtAuthMiddleware) { secured in
            secured.get("logout", handler: controller.logout)
            secured.patch("token", "regenerate", handler: controller.regenerate)
            secured.get("me", handler: controller.me)
        }
    }
}
