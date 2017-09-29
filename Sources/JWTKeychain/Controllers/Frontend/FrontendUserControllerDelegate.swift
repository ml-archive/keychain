import Authentication
import Flash
import Fluent
import Foundation
import Forms
import HTTP
import JWT
import JWTProvider
import SMTP
import Vapor

public protocol PasswordResetInfoType: FieldsetRepresentable {
    var email: String? { get }
    var password: String? { get }
    var isValid: Bool { get }
}

public protocol PasswordResettable {
    static func extractPasswordResetInfo(
        from: Request
    ) throws -> PasswordResetInfoType
}

public typealias PasswordResettableUser =
    EmailAddressRepresentable &
    Entity &
    PasswordAuthenticatable &
    PasswordUpdateable &
    PayloadAuthenticatable &
    PasswordResettable

open class FrontendUserControllerDelegate<U: PasswordResettableUser>:
    FrontendUserControllerDelegateType
{
    public let pathToFormView: String

    public init(settings: Settings) {
        pathToFormView = settings.pathToFormView
    }

    /// Shows the form where the user can reset the password
    ///
    /// - Parameters
    ///   - request: current request
    ///   - token: jwt token string
    ///   - viewRenderer: view renderer to use
    ///
    /// - Returns: response (view or redirect)
    open func resetPasswordForm(
        request: Request,
        token: String,
        verifiedJWT jwt: JWT,
        viewRenderer: ViewRenderer
    ) throws -> ResponseRepresentable {
        let fieldset = try request.fieldset ??
            U.extractPasswordResetInfo(from: request)
                .makeFieldset(withValidation: false)

        return try viewRenderer.make(
            pathToFormView,
            ViewData(
                fieldset: fieldset,
                request: request,
                other: ViewData(["token": .string(token)])
            )
        )
    }

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
        let passwordResetInfo = try U.extractPasswordResetInfo(from: request)

        // prepare common response
        let fieldset = try passwordResetInfo.makeFieldset(withValidation: true)
        let redirectToForm = Response(redirect: formPath).setFieldset(fieldset)

        // ensure form values are valid
        guard
            let password = passwordResetInfo.password,
            passwordResetInfo.isValid
        else {
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
        guard passwordResetInfo.email?.lowercased() ==
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
