import JWTProvider
import Vapor

public struct TokenGenerators {
    internal let apiAccess: ExpireableSigner
    internal let refresh: ExpireableSigner?
    internal let resetPassword: ExpireableSigner
}

extension TokenGenerators {
    public var apiAccessTokenGenerator: ExpireableSigner {
        return apiAccess
    }

    public var refreshTokenGenerator: ExpireableSigner? {
        return refresh
    }

    public var resetPasswordTokenGenerator: ExpireableSigner {
        return resetPassword
    }
}

extension TokenGenerators {
    init(settings: Settings, signerMap: SignerMap) throws {
        apiAccess = try ExpireableSigner(
            signerParameters: settings.apiAccess,
            signerMap: signerMap
        )

        if let refreshToken = settings.refreshToken {
            refresh = try ExpireableSigner(
                signerParameters: refreshToken,
                signerMap: signerMap
            )
        } else {
            refresh = nil
        }

        resetPassword = try ExpireableSigner(
            signerParameters: settings.resetPassword,
            signerMap: signerMap
        )
    }
}

open class APIUserControllerDelegate<U: JWTKeychainUser>:
    APIUserControllerDelegateType
{
    open func register(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable {
        let user = try U.make(request: request)
        return try makeResponse(
            responseOptions: .all,
            tokenGenerators: tokenGenerators,
            user: user
        )
    }

    open func logIn(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable {
        let user = try U.logIn(request: request)
        return try makeResponse(
            responseOptions: .all,
            tokenGenerators: tokenGenerators,
            user: user
        )
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
        return try makeResponse(
            responseOptions: .access,
            tokenGenerators: tokenGenerators,
            user: user
        )
    }

    open func me(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable {
        let user: U = try request.auth.assertAuthenticated()
        return try makeResponse(
            responseOptions: .user,
            tokenGenerators: tokenGenerators,
            user: user
        )
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
        return try makeResponse(
            responseOptions: .user,
            tokenGenerators: tokenGenerators,
            user: user
        )
    }
}

// MARK: Helper

private extension APIUserControllerDelegate {
    func makeResponse(
        responseOptions: ResponseOptions,
        tokenGenerators: TokenGenerators,
        user: U
    ) throws -> ResponseRepresentable {
        var response = JSON()

        if responseOptions.contains(.access) {
            try response.set(
                "accessToken",
                tokenGenerators
                    .apiAccessTokenGenerator
                    .generateToken(for: user)
                    .string
            )
        }
        if
            responseOptions.contains(.refresh),
            let refreshTokenGenerator = tokenGenerators.refreshTokenGenerator
        {
            try response.set(
                "refreshToken",
                refreshTokenGenerator.generateToken(for: user).string
            )
        }
        if responseOptions.contains(.user) {
            if responseOptions == [.user] {
                // make an exception when only user is to be returned
                // -> return user as root level object
                return try user.makeJSON()
            } else {
                try response.set("user", user)
            }
        }

        return response
    }

    func status(_ status: String) -> ResponseRepresentable {
        return JSON(["status": .string(status)])
    }
}

private struct ResponseOptions: OptionSet {
    let rawValue: Int

    static let access = ResponseOptions(rawValue: 1 << 0)
    static let refresh = ResponseOptions(rawValue: 1 << 1)
    static let user = ResponseOptions(rawValue: 1 << 2)

    static let all: ResponseOptions = [.access, .refresh, .user]
}

