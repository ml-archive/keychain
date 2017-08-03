import Authentication
import Flash
import Fluent
import Forms
import Foundation
import HTTP
import JWT
import JWTProvider
import SMTP
import Vapor

public typealias PasswordResettableUser = PayloadAuthenticatable & Entity &
    PasswordAuthenticatable & EmailAddressRepresentable & PasswordUpdateable

public protocol PasswordUpdateable {
    func updatePassword(to: String) throws
}

extension User: PasswordUpdateable {
    public func updatePassword(to password: String) throws {
        try update(password: User.passwordHasher.hash(Valid(password)))
    }
}

/// Controller for reset password requests
open class FrontendResetPasswordController<U: PasswordResettableUser>:
    FrontendResetPasswordControllerType {
    fileprivate let claims: [Claim]
    fileprivate let signer: Signer
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
        let user: U

        do {
            let payload = try U.PayloadType(json: jwt.payload)
            user = try U.authenticate(payload)
        } catch {
            return redirectToForm.flash(.error, "User not found.")
        }

        // check that the user knows the right email address
        guard form.email.value == user.emailAddress.address else {
            return redirectToForm.flash(.error, "Emails do not match.")
        }
 
        // check that the password hash is still the same as when the token
        // was issued
        do {
            let passwordClaim = try PasswordClaim(user: user)
            try jwt.verifyClaims([passwordClaim])
        } catch {
            return redirectToForm.flash(.error, "Password already changed." +
                " Request another password reset to change it again."
            )
        }

        try user.updatePassword(to: password)
        try user.save()

        return redirectToForm
            .flash(.success, "Password changed. You can close this page now.")
    }
}

// MARK: Helper

extension FrontendResetPasswordController {
    fileprivate func verifiedJWT(from token: String) throws -> JWT {
        let jwt = try JWT(token: token)

        try jwt.verifyClaims(claims)
        try jwt.verifySignature(using: signer)

        return jwt
    }
}
