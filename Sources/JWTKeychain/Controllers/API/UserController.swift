import Vapor
import Authentication
import Foundation
import HTTP
import JWT
import Flash

/// Controller for user api requests
open class UserController: UserControllerType {
    /// Initializes the UsersController with a JWT configuration.
    ///
    /// - Parameters:
    /// configuration : the JWT configuration to be used to generate user tokens.
    /// drop : the Droplet instance

    public let configuration: ConfigurationType
    private let drop: Droplet
    private let mailer: MailerType
    
    required public init(configuration: ConfigurationType, drop: Droplet, mailer: MailerType) {
        self.configuration = configuration
        self.mailer = mailer
        self.drop = drop
    }

    open func register(request: Request) throws -> ResponseRepresentable {

        // TODO: implement
        return ""

//        do {
//            // Validate request
//            let validator = try T.Validator(validating: request.data)
//            var user = T(validated: validator)
//            try user.save()
//            let token = try self.configuration.generateToken(user: user)
//            return try user.makeJSON(token: token)
//        } catch FormError.validationFailed(let fieldset) {
//            throw Abort(status: Status.preconditionFailed, message: "Invalid data: \(fieldset.errors)")
//        } catch {
//            throw Abort(Status.unprocessableEntity, metadata: "Could not create user")
//        }
    }

    open func login(request: Request) throws -> ResponseRepresentable {
        // TODO: implement
        return ""

        // Get our credentials
//        guard let email = request.data["email"]?.string, let password = request.data["password"]?.string else {
//            throw Abort(Status.preconditionFailed, metadata: "Missing email or password")
//        }
//
//        let credentials = EmailPassword(email: email, password: password)
//
//        do {
//            try request.auth.login(credentials)
//            let user: T = try request.user()
//            let token = try configuration.generateToken(user: user)
//            return try user.makeJSON(token: token)
//        } catch _ {
//            throw Abort(.badRequest, metadata: "Invalid email or password")
//        }
    }

    open func logout(request: Request) throws -> ResponseRepresentable {
        // TODO: implement
        return ""

//        // Clear the session
//        request.subject.logout()
//        return try JSON(node: ["success": true])
    }

    open func regenerate(request: Request) throws -> ResponseRepresentable {
        // TODO: implement
        return ""

//        let user: T = try request.user()
//        let token = try self.configuration.generateToken(user: user)
//        return try JSON(node: ["token": token])
    }

    open func me(request: Request) throws -> ResponseRepresentable {
        // TODO: implement
        return ""

//        let user: T = try request.user()
//        let token = try self.configuration.generateToken(user: user)
//        return try user.makeJSON(token: token)
    }

    open func resetPasswordEmail(request: Request) throws -> ResponseRepresentable {
        // TODO: implement
        return ""

//        if request.data["email"]?.string == nil {
//            throw Abort(.preconditionFailed, metadata: "Email is required")
//        }
//
//        let email: Valid<Email> = try request.data["email"].validated()
//
//        guard let user = try T.query().filter("email", email.value).first() else {
//            return JSON(["success": "Instructions were sent to the provided email"])
//        }
//
//        let token = try self.configuration.generateResetPasswordToken(user: user)
//
//        let base64EncodedToken = try Base64Encoding().encode(token.bytes)
//
//        // Send mail
//        try self.mailer.sendResetPasswordMail(user: user, token: base64EncodedToken, subject: "Reset Password")
//
//        return JSON(["success": "Instructions were sent to the provided email"])
    }
}
