import Vapor
import Auth
import Routing
import HTTP

public struct UserRoutes: RouteCollection {
    public typealias Wrapped = Responder

    let drop: Droplet
    private let authMiddleware: Middleware
    private let jwtAuthMiddleware: JWTAuthMiddleware
    private let protectMiddleware: ProtectMiddleware

    public init(
        drop: Droplet,
        authMiddleware: Middleware = AuthMiddleware<User>(),
        jwtAuthMiddleware: JWTAuthMiddleware = JWTAuthMiddleware(),
        protectMiddleware: ProtectMiddleware = ProtectMiddleware(
            error: Abort.custom(
                status: .unauthorized,
                message: Status.unauthorized.reasonPhrase
            )
        )
    ) {
        self.drop = drop
        self.authMiddleware = authMiddleware
        self.jwtAuthMiddleware = jwtAuthMiddleware
        self.protectMiddleware = protectMiddleware
    }

    public func build<Builder: RouteBuilder>(
        _ builder: Builder
    ) where Builder.Value == Responder {

        // Define the controller
        let controller = UsersController()
        
        // Get the base path group
        let path = builder.grouped("users")
        
        // Public routes
        path.post(handler: controller.register)

        // Auth routes
        path.group(authMiddleware) { jwtRoutes in
            jwtRoutes.post("login", handler: controller.login)
        }
        
        // Protected routes
        path.group(jwtAuthMiddleware, authMiddleware, protectMiddleware) { secured in
            secured.get("logout", handler: controller.logout)
            secured.patch("token", "regenerate", handler: controller.regenerate)
            secured.get("me", handler: controller.me)
        }
    }
}
