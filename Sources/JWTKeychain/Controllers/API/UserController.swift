import Vapor
import Auth
import Foundation
import HTTP
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import VaporForms
import VaporJWT
import Flash

/// Controller for user api requests
open class UserController: UserControllerType {
    
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
            let token = try self.configuration.generateToken(user: user)
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
            let token = try configuration.generateToken(user: user)
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
        let token = try self.configuration.generateToken(user: user)
        return try JSON(node: ["token": token])
    }

    open func me(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        let token = try self.configuration.generateToken(user: user)
        return try user.makeJSON(token: token)
    }

    open func resetPasswordEmail(request: Request) -> ResponseRepresentable {
        do {

            guard
                let email = request.data["email"]?.string,
                let user: User = try User.query().filter("email", email).first() else {
                    return JSON(["success": "Instructions were sent to the provided email"])
            }

            let token = try self.configuration.generateResetPasswordToken(user: user)

            // Send mail
            try Mailer.sendResetPasswordMail(drop: self.drop, user: user, token: token)
            
            return JSON(["success": "Instructions were sent to the provided email"])
        } catch {
            return JSON(["error": "An error occured."])
        }
    }

    open func resetPasswordForm(request: Request, token: String) throws -> View {

        // Validate token
        if try !self.configuration.validateToken(token: token) {
            throw Abort.notFound
        }

        let jwt = try JWT(token: token)

        guard
            let userId = jwt.payload["user"]?.object?["id"]?.int,
            let _ = try User.query().filter("id", userId).first() else {
            throw Abort.notFound
        }

        return try drop.view.make("ResetPassword/form", ["token": token])
    }

    open func resetPasswordChange(request: Request) throws -> Response {

        guard let token = request.data["token"]?.string else {
            return Response(redirect: "/api/v1/users/reset-password/form")
                .flash(.error, "Missing token")
        }

        guard let email = request.data["email"]?.string else {
            return Response(redirect: "/api/v1/users/reset-password/form")
                .flash(.error, "Missing email")
        }

        guard let password = request.data["password"]?.string else {
            return Response(redirect: "/api/v1/users/reset-password/form")
                .flash(.error, "Missing password")
        }

        guard let passwordConfirmation = request.data["password_confirmation"]?.string else {
            return Response(redirect: "/api/v1/users/reset-password/form")
                .flash(.error, "Missing password confirmation")
        }

        // Validate token
        if try !self.configuration.validateToken(token: token) {
            return Response(redirect: "/api/v1/users/reset-password/form")
                .flash(.error, "Token is invalid")
        }

        let jwt = try JWT(token: token)

        guard
            let userId = jwt.payload["user"]?.object?["id"]?.int,
            let userPasswordHash = jwt.payload["password"]?.string,
            var user = try User.query().filter("id", userId).first() else {
                return Response(redirect: "/api/v1/users/reset-password/form")
                    .flash(.error, "Token is invalid")
        }

        if user.email != email {
            return Response(redirect: "/api/v1/users/reset-password/form")
                .flash(.error, "Email did not match")
        }

        if user.password != userPasswordHash {
            return Response(redirect: "/api/v1/users/reset-password/form")
                .flash(.error, "Password already changed. Cannot use the same token again.")
        }

        if password != passwordConfirmation {
            return Response(redirect: "/api/v1/users/reset-password/form")
                .flash(.error, "Password and password confirmation don't match")
        }

        user.password = BCrypt.hash(password: password)
        try user.save()

        return Response(redirect: "/api/v1/users/reset-password/form")
            .flash(.success, "Password changed. You can close this page now.")
    }
}
