import JWTProvider
import Vapor

open class APIUserControllerDelegate<U: JWTKeychainUser>:
    APIUserControllerDelegateType
{
    public init() {}

    open func register(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable {
        let user = try U.make(request: request)
        try user.save()
        return try tokenGenerators.makeResponse(for: user, withOptions: .all)
    }

    open func logIn(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable {
        let user = try U.logIn(request: request)
        return try tokenGenerators.makeResponse(for: user, withOptions: .all)
    }

    open func logOut(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable {
        _ = try U.logOut(request: request)
        return status("ok")
    }

    open func regenerate(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable {
        let user: U = try request.auth.assertAuthenticated()
        return try tokenGenerators.makeResponse(for: user, withOptions: .access)
    }

    open func me(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable {
        let user: U = try request.auth.assertAuthenticated()
        return try tokenGenerators.makeResponse(for: user, withOptions: .user)
    }

    open func resetPasswordEmail(
        request: Request,
        tokenGenerators: TokenGenerators,
        passwordResetMailer: PasswordResetMailerType
    ) throws -> ResponseRepresentable {
        do {
            let user = try U.find(request: request)
            let token = try tokenGenerators
                .resetPasswordTokenGenerator
                .generateToken(for: user)
            try passwordResetMailer.sendResetPasswordMail(
                user: user,
                resetToken: token,
                subject: "Reset Password"
            )
        } catch let error as AbortError where error.status == .notFound {
            // ignore "notFound" errors and pretend the operation succeeded
        }

        return status("Instructions were sent to the provided email")
    }

    open func update(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable {
        let user = try U.update(request: request)
        try user.save()
        return try tokenGenerators.makeResponse(for: user, withOptions: .user)
    }
}

extension APIUserControllerDelegate {
    func status(_ status: String) -> ResponseRepresentable {
        return JSON(["status": .string(status)])
    }
}
