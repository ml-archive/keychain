import Vapor
import Auth
import Foundation
import HTTP
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import VaporForms



/// Controller for user api requests
open class UsersController {
    
    
    /// Registers a user on the DB
    ///
    /// - Parameter request: current request
    /// - Returns: JSON response with User data
    /// - Throws: on invalid data or if unable to store data on the DB
    func register(request: Request) throws -> ResponseRepresentable {
        
        do{
            
            // Validate request
            let requestData = try StoreRequest(validating: request.data)
            
            var user = User(
                name: requestData.name,
                email: requestData.email,
                password: requestData.password
            )
            
            try user.save()
            
            return try user.makeJSON(withToken: true)
            
        }catch FormError.validationFailed(let fieldset) {
            throw Abort.custom(status: Status.preconditionFailed, message: "Invalid data: \(fieldset.errors)")
        }catch {
            throw Abort.custom(status: Status.unprocessableEntity, message: "Could not create user")
        }
        
    }
    
    
    /// Logins the user on the system, giving the token back
    ///
    /// - Parameter request: current request
    /// - Returns: JSON response with User data
    /// - Throws: on invalid data or wrong credentials
    func login(request: Request) throws -> ResponseRepresentable {
        
        // Get our credentials
        guard let email = request.data["email"]?.string, let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.preconditionFailed, message: "Missing email or password")
        }
        
        let credentials = EmailPassword(email: email, password: password)
        
        do {
            
            try request.auth.login(credentials)
            
            return try request.user().makeJSON(withToken: true)
            
        } catch _ {
            
            throw Abort.custom(status: Status.badRequest, message: "Invalid email or password")
            
        }
    }
    
    
    /// Logs the user out of the system
    ///
    /// - Parameter request: current request
    /// - Returns: JSON success response
    /// - Throws: if not able to find token
    func logout(request: Request) throws -> ResponseRepresentable {
        
        // Clear the session
        request.subject.logout()
        
        return try JSON(node: ["success": true])
    }
    
    
    /// Generates a new token for the user
    ///
    /// - Parameter request: current request
    /// - Returns: JSON with token
    /// - Throws: if not able to generate token
    func regenerate(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        
        return try JSON(node: ["token": user.generateToken()])
    }
    
    
    /// Returns the authenticated user data
    ///
    /// - Parameter request: current request
    /// - Returns: JSON response with User data
    /// - Throws: on no user found
    func me(request: Request) throws -> ResponseRepresentable {
        return try request.user().makeJSON()
    }
    
}
