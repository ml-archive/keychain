import Vapor
import Auth

open class UserRoutes {
    /// Empty initializer.
    public init() {}
    
    /// Registers the routes on the given droplet
    ///
    /// - Parameter drop: droplet instance
    public func register(drop: Droplet) throws {
        
        // Define the controller
        let controller = UsersController()
        
        // Get the base path group
        let path = drop.grouped("api").grouped("v1").grouped("users")
        
        // Set protected middleware
        let protect = ProtectMiddleware(
            error: Abort.custom(status: .unauthorized, message: "Unauthorized")
        )
        
        // Public routes
        path.post(handler: controller.register)
        path.post("login", handler: controller.login)
        
        // Protected routes
        path.group(JWTAuthMiddleware(), protect) { secured in
            secured.get("logout", handler: controller.logout)
            secured.patch("token", "regenerate", handler: controller.regenerate)
            secured.get("me", handler: controller.me)
        }
        
    }
    
}
