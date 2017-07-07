import Authentication
import Flash
import Foundation
import HTTP
import JWT
import Vapor

/// Controller for reset password requests
open class FrontendResetPasswordController: FrontendResetPasswordControllerType {
    private let claims: [Claim]
    private let signer: Signer
    private let viewRenderer: ViewRenderer

    required public init(
        claims: [Claim] = [ExpirationTimeClaim()],
        signer: Signer,
        viewRenderer: ViewRenderer)
    {
        self.claims = claims
        self.signer = signer
        self.viewRenderer = viewRenderer
    }

    open func resetPasswordForm(request: Request) throws -> View {
        do {
            let token = try request.parameters.next(String.self)
            _ = try verifiedJWT(from: token)

            return try viewRenderer.make("ResetPassword/user-form", [
                "token": token,
                "resetPasswordFields": ResetPasswordForm(content: request.data)
                ], for: request)
        } catch {
            throw Abort(.badRequest, metadata: "The provided token is not valid. Try again with a valid token.")
        }
    }

    private func verifiedJWT(from token: String) throws -> JWT {
        let jwt = try JWT(token: token)

        try jwt.verifySignature(using: signer)
        try jwt.verifyClaims(claims)

        return jwt
    }

    open func resetPasswordChange(request: Request) throws -> Response {

        func reload(withMessage message: String) -> Response {
            return Response(redirect: request.uri.path)
                .flash(.error, message)
        }

        do {
            guard let token = request.data["token"]?.string else {
                return reload(withMessage: "Token is invalid")
            }




//            let user = try getUser(from: token)

//            // Validate token
//            do {
//                try self.configuration.validateToken(token: decodedToken)
//            } catch Configuration.Error.invalidClaims {
//                return Response(redirect: currentPath)
//                    .flash(.error, "Token is invalid")
//            }
//
//            let jwt = try JWT(token: decodedToken)
//
//            guard
//                let userId = jwt.payload["user"]?.object?["id"]?.int,
//                let userPasswordHash = jwt.payload["user"]?.object?["password"]?.string,
//                var user = try User.query().filter("id", userId).first() else {
//                    return Response(redirect: currentPath)
//                        .flash(.error, "Token is invalid")
//            }

//            if user.email != requestData.email {
//                return Response(redirect: currentPath)
//                    .flash(.error, "Email did not match")
//            }
//
//            if user.password != userPasswordHash {
//                return Response(redirect: currentPath)
//                    .flash(.error, "Password already changed. Cannot use the same token again.")
//            }
//
//            if requestData.password != requestData.passwordConfirmation {
//                return Response(redirect: currentPath)
//                    .flash(.error, "Password and password confirmation don't match")
//            }
//
//            user.password = try Hash.make(message: password).makeString()
//            try user.save()
//
//            return Response(redirect: currentPath)
//                .flash(.success, "Password changed. You can close this page now.")
//
//
//        } catch FormError.validationFailed(let fieldset) {
//
//            return Response(redirect: resetPasswordBaseUrl + (request.data["token"]?.string ?? "invalid"))
//                .flash(.error, "Validation error(s)")
//                .withFieldset(fieldset)
//
        } catch {
//
//            return Response(redirect: "/reset-password/form/" + (request.data["token"]?.string ?? "invalid"))
//                .flash(.error, "Something went wrong")
        }

        return Response(redirect: "")
    }
}
