import Vapor
import Auth
import Foundation
import HTTP
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import VaporForms
import JWT
import Flash

/// Controller for reset password requests
open class FrontendResetPasswordController: FrontendResetPasswordControllerType {

    public let configuration: ConfigurationType

    private let drop: Droplet

    required public init(drop: Droplet, configuration: ConfigurationType) {
        self.configuration = configuration
        self.drop = drop
    }

    open func resetPasswordForm(request: Request, token: String) throws -> View {
        
        // Validate token
        do {
            try self.configuration.validateToken(token: token)
            
            let jwt = try JWT(token: token)
            
            guard
                let userId = jwt.payload["user"]?.object?["id"]?.int,
                let _ = try User.query().filter("id", userId).first() else {
                    throw Abort.notFound
            }
            
        } catch {
            throw Abort.custom(status: .badRequest, message: "The provided token does not validate. Try to reset your password again")
        }

        return try drop.view.make("ResetPassword/form", ["token": token], for: request)
    }

    open func resetPasswordChange(request: Request) throws -> Response {

        do {
            // Validate request
            let requestData = try ResetPasswordRequest(validating: request.data)

            // Validate token
            do {
                try self.configuration.validateToken(token: requestData.token)
            } catch Configuration.Error.invalidClaims {
                return Response(redirect: "/reset-password/form/" + requestData.token)
                    .flash(.error, "Token is invalid")
            }

            let jwt = try JWT(token: requestData.token)

            guard
                let userId = jwt.payload["user"]?.object?["id"]?.int,
                let userPasswordHash = jwt.payload["user"]?.object?["password"]?.string,
                var user = try User.query().filter("id", userId).first() else {
                    return Response(redirect: "/reset-password/form/" + requestData.token)
                        .flash(.error, "Token is invalid")
            }

            if user.email != requestData.email {
                return Response(redirect: "/reset-password/form/" + requestData.token)
                    .flash(.error, "Email did not match")
            }

            if user.password != userPasswordHash {
                return Response(redirect: "/reset-password/form/" + requestData.token)
                    .flash(.error, "Password already changed. Cannot use the same token again.")
            }

            if requestData.password != requestData.passwordConfirmation {
                return Response(redirect: "/reset-password/form/" + requestData.token)
                    .flash(.error, "Password and password confirmation don't match")
            }

            user.password = BCrypt.hash(password: requestData.password)
            try user.save()

            return Response(redirect: "/reset-password/form/" + requestData.token)
                .flash(.success, "Password changed. You can close this page now.")


        } catch FormError.validationFailed(let fieldset) {

            let response = Response(redirect: "/reset-password/form/" + (request.data["token"]?.string ?? "invalid"))
                .flash(.error, "Data is invalid")
            
            response.storage["_fieldset"] = try fieldset.makeNode()
            
            return response
            
        } catch {
            return Response(redirect: "/reset-password/form/" + (request.data["token"]?.string ?? "invalid"))
                .flash(.error, "Something went wrong")
        }
        
    }
}
