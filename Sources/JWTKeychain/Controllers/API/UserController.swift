import Vapor
import Auth
import Foundation
import HTTP
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import VaporForms

/// Basic controller functionality for a user than can be authorized.
open class UserController: UserControllerType {
    private let configuration: ConfigurationType

    required public init(configuration: ConfigurationType) {
        self.configuration = configuration
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
}
