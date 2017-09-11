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

public typealias PasswordResettableUser =
    EmailAddressRepresentable &
    Entity &
    PasswordAuthenticatable &
    PasswordUpdateable &
    PayloadAuthenticatable

open class FrontendUserControllerDelegate<U: PasswordResettableUser>:
    FrontendUserControllerDelegateType
{
    /// Validates the reset request and actually changes the password
    ///
    /// - Parameter request: current request
    /// - Returns: success or error response
    /// - Throws: if something goes wrong
    open func resetPasswordChange(
        request: Request,
        verifiedJWT jwt: JWT,
        formPath: String
    ) throws -> ResponseRepresentable {

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

        // load user that the token was made for
        let user: U

        do {
            let payload = try U.PayloadType(json: jwt.payload)
            user = try U.authenticate(payload)
        } catch {
            return redirectToForm.flash(.error, "User not found.")
        }

        // check that the user knows the right email address
        guard form.email.value?.lowercased() ==
            user.emailAddress.address.lowercased() else {
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
