import Vapor
import Auth

open class UserRoutes {
    
    
    /// Registers the routes on the given droplet
    ///
    /// - Parameter drop: droplet instance
    func register(drop: Droplet) throws{
        
        // Define the controller
        let controller = UsersController()
        
        // Get the base path group
        let path = drop.grouped("api").grouped("v1").grouped("users")
        
        // Set protected middleware
        let protect = ProtectMiddleware(
            error: Abort.custom(status: .unauthorized, message: "Unauthorized")
        )
        
        let jwtMiddleware = try JWTAuthMiddleware(drop: drop)
        
        // Public routes
        path.post(handler: controller.register)
        path.post("login", handler: controller.login)
        
        // Protected routes
        path.group(jwtMiddleware, protect) { secured in
            secured.get("logout", handler: controller.logout)
            secured.patch("token", "regenerate", handler: controller.regenerate)
            secured.get("me", handler: controller.me)
        }
        
    }
    
}
