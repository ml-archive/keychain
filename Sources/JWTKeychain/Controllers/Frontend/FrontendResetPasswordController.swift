import Authentication
import Flash
import Forms
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
        let token = try request.parameters.next(String.self)

        do {
            _ = try verifiedJWT(from: token)
        } catch {
            throw Abort(
                .badRequest,
                metadata: "The provided token is not valid."
            )
        }

        let fieldSet = try request.fieldSet ??
            ResetPasswordForm(makeAllFieldsOptional: true).makeFieldSet()

        return try viewRenderer.make(
            "ResetPassword/user-form",
            [
                "token": .string(token),
                Node.fieldSetViewDataKey: fieldSet
            ],
            for: request)
    }

    open func resetPasswordChange(request: Request) throws -> Response {
        let token = try request.parameters.next(String.self)

        // determine path to reset password form relative to current path
        let formPath = request.uri
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("form")
            .appendingPathComponent(token)
            .path

        // extract values from the request
        let form: ResetPasswordForm = try request.createForm()

        // prepare common response
        let redirectToForm = try Response(redirect: formPath)
            .setFieldSet(form.makeFieldSet())

        // ensure form values are valid
        guard let password = form.password.value, form.isValid else {
            return redirectToForm
                .flash(.error, "Please correct the highlighted fields below.")
        }

        // verify JWT
        let jwt: JWT

        do {
            jwt = try verifiedJWT(from: token)
        } catch {
            return redirectToForm.flash(.error, "Invalid token.")
        }

        // load user that the token was made for
        let user: User

        do {
            let payload = try User.PayloadType(json: jwt.payload)
            user = try User.authenticate(payload)
        } catch {
            return redirectToForm.flash(.error, "User not found.")
        }

        // check that the user knows the right email address
        guard form.email.value == user.email else {
            return redirectToForm.flash(.error, "Emails do not match.")
        }

        do {
            let passwordClaim = try PasswordClaim(user: user)
            try jwt.verifyClaims([passwordClaim])
        } catch {
            return redirectToForm.flash(.error, "Password already changed." +
                " Request another password reset to change it again."
            )
        }

        try user.update(password: User.passwordHasher.hash(Valid(password)))

        return redirectToForm
            .flash(.success, "Password changed. You can close this page now.")
    }
}

// MARK: Helper

extension FrontendResetPasswordController {
    fileprivate func verifiedJWT(from token: String) throws -> JWT {
        let jwt = try JWT(token: token)

        // TODO: reenable
        //        try jwt.verifyClaims(claims)
        //        try jwt.verifySignature(using: signer)

        return jwt
    }
}
