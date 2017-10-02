import Authentication
import HTTP
import JWT
import JWTProvider
import Vapor

/// Controller for reset password requests
internal class FrontendUserController {
    private let claims: [Claim]
    private let signer: Signer
    private let viewRenderer: ViewRenderer
    private let delegate: FrontendUserControllerDelegateType

    internal init(
        claims: [Claim] = [ExpirationTimeClaim()],
        signer: Signer,
        viewRenderer: ViewRenderer,
        delegate: FrontendUserControllerDelegateType
    ) {
        self.claims = claims
        self.signer = signer
        self.viewRenderer = viewRenderer
        self.delegate = delegate
    }

    internal func resetPasswordForm(request: Request) throws -> ResponseRepresentable {
        let token = try request.parameters.next(String.self)

        do {
            let jwt = try verifiedJWT(from: token)
            return try delegate.resetPasswordForm(
                request: request,
                token: token,
                verifiedJWT: jwt,
                viewRenderer: viewRenderer
            )
        } catch let error as JWTError {
            return delegate.handleInvalidJWT(
                request: request,
                token: token,
                jwtError: error,
                formPath: request.uri.path
            )
        }
    }

    internal func resetPasswordChange(
        request: Request
    ) throws -> ResponseRepresentable {
        let token = try request.parameters.next(String.self)

        // determine path to reset password form relative to current path
        let formPath = request.uri
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("form")
            .appendingPathComponent(token)
            .path

        do {
            let jwt = try verifiedJWT(from: token)
            return try delegate.resetPasswordChange(
                request: request,
                verifiedJWT: jwt,
                formPath: formPath
            )
        } catch let error as JWTError {
            return delegate.handleInvalidJWT(
                request: request,
                token: token,
                jwtError: error,
                formPath: formPath
            )
        }
    }

    private func verifiedJWT(from token: String) throws -> JWT {
        let jwt = try JWT(token: token)

        try jwt.verifyClaims(claims)
        try jwt.verifySignature(using: signer)

        return jwt
    }
}
