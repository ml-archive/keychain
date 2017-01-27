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
    
    public let configuration: ConfigurationType
    
    private let drop: Droplet
    
    private let mailer: MailerType
    
    required public init(configuration: ConfigurationType, drop: Droplet, mailer: MailerType) {
        self.configuration = configuration
        self.mailer = mailer
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
    
    open func resetPasswordEmail(request: Request) throws -> ResponseRepresentable {
        
        if request.data["email"]?.string == nil {
            throw Abort.custom(status: .preconditionFailed, message: "Email is required")
        }
        
        let email: Valid<Email> = try request.data["email"].validated()
        
        guard
            let user: User = try User.query().filter("email", email.value).first() else {
                return JSON(["success": "Instructions were sent to the provided email"])
        }
        
        let token = try self.configuration.generateResetPasswordToken(user: user)
        
        // Send mail
        try self.mailer.sendResetPasswordMail(user: user, token: token, subject: "Reset Password")
        
        return JSON(["success": "Instructions were sent to the provided email"])
        
    }
    
    open func resetPasswordForm(request: Request, token: String) throws -> View {
        // Validate token
        if try !self.configuration.validateToken(token: token) {
            throw Abort.notFound
        }
        
        let jwt = try JWT(token: token)
        
        guard
            let userId = jwt.payload["user"]?.object?["id"]?.int,
            try User.query().filter("id", userId).first() != nil else {
                throw Abort.notFound
        }
        
        return try drop.view.make("ResetPassword/form", ["token": token], for: request)
    }
    
    open func resetPasswordChange(request: Request) throws -> Response {
        guard let token = request.data["token"]?.string else {
            throw Abort.badRequest
        }
        let redirectUrl = "/api/v1/users/reset-password/form/\(token)"
        
        do {
            // Validate request
            let requestData = try ResetPasswordRequest(validating: request.data)
            
            // Validate token
            if try !self.configuration.validateToken(token: requestData.token) {
                return Response(redirect: redirectUrl)
                    .flash(.error, "Token is invalid")
            }
            
            let jwt = try JWT(token: requestData.token)
            
            guard
                let userId = jwt.payload["user"]?.object?["id"]?.int,
                let userPasswordHash = jwt.payload["user"]?.object?["password"]?.string,
                var user = try User.query().filter("id", userId).first() else {
                    return Response(redirect: redirectUrl)
                        .flash(.error, "Token is invalid")
            }
            
            if user.email != requestData.email {
                return Response(redirect: redirectUrl)
                    .flash(.error, "Email did not match")
            }
            
            if user.password != userPasswordHash {
                return Response(redirect: redirectUrl)
                    .flash(.error, "Password already changed. Cannot use the same token again.")
            }
            
            if requestData.password != requestData.passwordConfirmation {
                return Response(redirect: redirectUrl)
                    .flash(.error, "Password and password confirmation don't match")
            }
            
            user.password = BCrypt.hash(password: requestData.password)
            try user.save()
            
            return Response(redirect: redirectUrl)
                .flash(.success, "Password changed. You can close this page now.")
            
            
        } catch FormError.validationFailed(let fieldset) {
            
            let response = Response(redirect: redirectUrl).flash(.error, "Data is invalid")
            response.storage["_fieldset"] = try fieldset.makeNode()
            
            return response
            
        } catch {
            return Response(redirect: redirectUrl)
                .flash(.error, "Something went wrong")
        }
        
    }
}
