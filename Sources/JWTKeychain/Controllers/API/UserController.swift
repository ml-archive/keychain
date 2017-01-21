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
    
    private let configuration: ConfigurationType

    private let drop: Droplet

    required public init(configuration: ConfigurationType, drop: Droplet) {
        self.configuration = configuration
        self.drop = drop
    }

    open func register(request: Request) throws -> ResponseRepresentable {
        do {
            // Validate request
            let requestData = try StoreRequest(validating: request.data)

            var user = User(
                name: requestData.name,
                email: requestData.email,
                password: requestData.password
            )

            try user.save()
            let token = try self.configuration.generateToken(userId: user.id!)
            return try user.makeJSON(token: token)

        } catch FormError.validationFailed(let fieldset) {
            throw Abort.custom(status: Status.preconditionFailed, message: "Invalid data: \(fieldset.errors)")
        } catch {
            throw Abort.custom(status: Status.unprocessableEntity, message: "Could not create user")
        }
    }

    open func login(request: Request) throws -> ResponseRepresentable {
        // Get our credentials
        guard let email = request.data["email"]?.string, let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.preconditionFailed, message: "Missing email or password")
        }

        let credentials = EmailPassword(email: email, password: password)

        do {

            try request.auth.login(credentials)
            let user = try request.user()
            let token = try configuration.generateToken(userId: user.id!)
            return try user.makeJSON(token: token)

        } catch _ {
            throw Abort.custom(status: Status.badRequest, message: "Invalid email or password")
        }
    }

    open func logout(request: Request) throws -> ResponseRepresentable {
        // Clear the session
        request.subject.logout()

        return try JSON(node: ["success": true])
    }

    open func regenerate(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        let token = try self.configuration.generateToken(userId: user.id!)
        return try JSON(node: ["token": token])
    }

    open func me(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        let token = try self.configuration.generateToken(userId: user.id!)
        return try user.makeJSON(token: token)
    }

    /// Reset password submit
    ///
    /// It's on purpose that we show a success message if user is not found.
    /// Else this action could be used to find emails in db
    ///
    /// - Parameter request: Request
    /// - Returns: Response
    public func resetPassword(request: Request) -> ResponseRepresentable {
        do {

            guard
                let email = request.data["email"]?.string,
                let user: User = try User.query().filter("email", email).first() else {
                    return JSON(["success": "Instructions were sent to the provided email"])
            }

            // Make a token
            let token = try self.configuration.generateToken(userId: user.id!)

            // Send mail
            try Mailer.sendResetPasswordMail(drop: self.drop, user: user, token: token)
            
            return JSON(["success": "Instructions were sent to the provided email"])
        } catch {
            return JSON(["error": "An error occured."])
        }
    }
}
