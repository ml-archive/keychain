import HTTP
import JWT
import Vapor

/// Defines basic authorization functionality.
public protocol FrontendUserControllerDelegateType {
    func resetPasswordForm(
        request: Request,
        token: String,
        verifiedJWT: JWT,
        viewRenderer: ViewRenderer
    ) throws -> ResponseRepresentable

    func resetPasswordChange(
        request: Request,
        verifiedJWT: JWT,
        formPath: String
    ) throws -> ResponseRepresentable

    func handleInvalidJWT(
        request: Request,
        token: String,
        jwtError: JWTError,
        formPath: String
    ) -> ResponseRepresentable
}

extension FrontendUserControllerDelegateType {

    /// Shows the form where the user can reset the password
    ///
    /// - Parameters
    ///   - request: current request
    ///   - token: jwt token string
    ///   - viewRenderer: view renderer to use
    ///
    /// - Returns: response (view or redirect)
    public func resetPasswordForm(
        request: Request,
        token: String,
        verifiedJWT jwt: JWT,
        viewRenderer: ViewRenderer
    ) throws -> ResponseRepresentable {
        let fieldSet = try request.fieldSet ??
            ResetPasswordForm(makeAllFieldsOptional: true).makeFieldSet()

        return try viewRenderer.make(
            "ResetPassword/resetPassword",
            ViewData(
                fieldSet: fieldSet,
                request: request,
                other: ViewData(["token": .string(token)])
            )
        )
    }

    /// Redirects to formPath with a default flash error message
    ///
    /// - Parameters
    ///   - request: current request
    ///   - token: raw jwt token as string
    ///   - jwtError: error causing the JWT to be invalid
    ///   - formPath: path of reset password form (for redirect)
    ///
    /// - Returns: a redirect response
    public func handleInvalidJWT(
        request: Request,
        token: String,
        jwtError: JWTError,
        formPath: String
    ) -> ResponseRepresentable {
        return Response(redirect: formPath).flash(.error, "Invalid token.")
    }
}
