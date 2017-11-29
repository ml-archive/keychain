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

public protocol PasswordResetInfoType:
    FieldsetRepresentable,
    ValidationModeValidatable
{
    var email: String? { get }
    var password: String? { get }
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

    /// Renders the form where the user can reset the password.
    ///
    /// - Parameters:
    ///   - request: current request
    ///   - token: jwt token string
    ///   - viewRenderer: renderer used to render the form
    /// - Returns: rendered form view
    /// - Throws: if processing the request or rendering the view fails.
    open func resetPasswordForm(
        request: Request,
        token: String,
        viewRenderer: ViewRenderer
    ) throws -> ResponseRepresentable {
        let fieldset = try request.fieldset ??
            U.extractPasswordResetInfo(from: request)
                .makeFieldset(inValidationMode: .none)

        return try viewRenderer.make(
            pathToFormView,
            ViewData(
                fieldset: fieldset,
                request: request,
                other: ViewData(["token": .string(token)])
            )
        )
    }

    /// Changes the password if the request is valid.
    ///
    /// - Parameters:
    ///   - request: current request
    ///   - verifiedJWT: a pre-verified JSON Web Token
    ///   - formPath: URL path to redirect to after successful reset or error
    /// - Returns: a redirect response
    /// - Throws: any error processing the form request
    open func resetPasswordChange(
        request: Request,
        verifiedJWT jwt: JWT,
        formPath: String
    ) throws -> ResponseRepresentable {
        let passwordResetInfo = try U.extractPasswordResetInfo(from: request)

        // prepare common response
        let fieldset = try passwordResetInfo
            .makeFieldset(inValidationMode: .all)
        let redirectToForm = Response(redirect: formPath).setFieldset(fieldset)

        // ensure form values are valid
        guard
            let password = passwordResetInfo.password,
            passwordResetInfo.isValid(inValidationMode: .all)
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
