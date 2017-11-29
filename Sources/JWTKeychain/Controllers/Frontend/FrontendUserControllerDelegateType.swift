import HTTP
import JWT
import Vapor

/// Defines basic authorization functionality.
public protocol FrontendUserControllerDelegateType {
    func resetPasswordForm(
        request: Request,
        token: String,
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
