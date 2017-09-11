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
    /// - parameter request: current request
    /// - parameter token: jwt token string
    /// - parameter viewRenderer: view renderer to use
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
    /// - parameter request: current request
    /// - parameter token: raw jwt token as string
    /// - parameter jwtError: error causing the JWT to be invalid
    /// - parameter formPath: path of reset password form (for redirect)
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
