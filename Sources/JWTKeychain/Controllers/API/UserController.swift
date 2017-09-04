import Foundation
import Vapor

/// Controller for user API requests
open class UserController<U: JWTKeychainUser>: UserControllerType {
    private let passwordResetMailer: PasswordResetMailerType
    fileprivate let apiAccessTokenGenerator: TokenGenerator
    fileprivate let refreshTokenGenerator: TokenGenerator?
    fileprivate let resetPasswordTokenGenerator: TokenGenerator

    required public init(
        passwordResetMailer: PasswordResetMailerType,
        apiAccessTokenGenerator: TokenGenerator,
        refreshTokenGenerator: TokenGenerator?,
        resetPasswordTokenGenerator: TokenGenerator
    ) {
        self.passwordResetMailer = passwordResetMailer
        self.apiAccessTokenGenerator = apiAccessTokenGenerator
        self.refreshTokenGenerator = refreshTokenGenerator
        self.resetPasswordTokenGenerator = resetPasswordTokenGenerator
    }

    /// Registers a user and created an instance in the database.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    open func register(request: Request) throws -> ResponseRepresentable {
        let user = try U.make(request: request)
        return try makeResponse(user: user, responseOptions: .all)
    }

    /// Logs the user in to the system, giving the token back.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on invalid data or wrong credentials.
    open func logIn(request: Request) throws -> ResponseRepresentable {
        let user = try U.logIn(request: request)
        return try makeResponse(user: user, responseOptions: .all)
    }

    /// Logs the user out of the system.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON success response.
    /// - Throws: if not able to find token.
    open func logOut(request: Request) throws -> ResponseRepresentable {
        _ = try U.logOut(request: request)
        return status("ok")
    }

    /// Generates a new token for the user.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON with token.
    /// - Throws: if not able to generate token.
    open func regenerate(request: Request) throws -> ResponseRepresentable {
        let user: U = try request.auth.assertAuthenticated()
        return try makeResponse(user: user, responseOptions: .access)
    }

    /// Returns the authenticated user data.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on no user found.
    open func me(request: Request) throws -> ResponseRepresentable {
        let user: U = try request.auth.assertAuthenticated()
        return try makeResponse(user: user, responseOptions: .user)
    }

    /// Requests a reset of password for the given email.
    ///
    /// - Parameter request: current request.
    /// - Returns: success or failure message
    open func resetPasswordEmail(
        request: Request
    ) throws -> ResponseRepresentable {
        do {
            let user = try U.find(request: request)
            let token = try resetPasswordTokenGenerator.generateToken(for: user)
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

    /// Update a user's info (including password)
    ///
    /// - Parameter request: current request.
    /// - Returns: success or failure message
    open func update(request: Request) throws -> ResponseRepresentable {
        let user = try U.update(request: request)
        return try makeResponse(user: user, responseOptions: .user)
    }
}

// MARK: Helper

private extension UserController {
    func makeResponse(
        user: U,
        responseOptions: ResponseOptions
    ) throws -> ResponseRepresentable {
        var response = JSON()

        if responseOptions.contains(.access) {
            try response.set(
                "accessToken",
                apiAccessTokenGenerator.generateToken(for: user).string
            )
        }
        if responseOptions.contains(.refresh),
            let refreshTokenGenerator = refreshTokenGenerator
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
