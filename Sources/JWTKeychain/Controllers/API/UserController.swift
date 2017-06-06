import Authentication
import JWT
import Punctual
import Vapor

/// Controller for user api requests
open class UserController<A: UserAuthenticating>: UserControllerType {
    private let hasher: HashProtocol
    private let mailer: MailerType
    fileprivate let signer: Signer
    private let userAuthenticator: A

    required public init(
        hasher: HashProtocol,
        mailer: MailerType,
        signer: Signer,
        userAuthenticator: A
    ) {
        self.hasher = hasher
        self.mailer = mailer
        self.signer = signer
        self.userAuthenticator = userAuthenticator
    }

    open func register(request: Request) throws -> ResponseRepresentable {
        let user = try userAuthenticator.makeUser(request: request, hasher: hasher)
        return try makeResponse(user: user, responseOptions: .all)
    }

    open func logIn(request: Request) throws -> ResponseRepresentable {
        let user = try userAuthenticator.logIn(request: request, hasher: hasher)
        return try makeResponse(user: user, responseOptions: .all)
    }

    open func logOut(request: Request) throws -> ResponseRepresentable {
        _ = try userAuthenticator.logOut(request: request)
        return status("success")
    }

    open func regenerate(request: Request) throws -> ResponseRepresentable {
        let user: A.U = try request.auth.assertAuthenticated()
        return try makeResponse(user: user, responseOptions: .access)
    }

    open func me(request: Request) throws -> ResponseRepresentable {
        let user: A.U = try request.auth.assertAuthenticated()
        return try makeResponse(user: user, responseOptions: .user)
    }

    open func resetPasswordEmail(request: Request) throws -> ResponseRepresentable {
        do {
            let user = try userAuthenticator.findByEmail(request: request)
            let accessToken = try makeToken(for: user, expirationDate: 1.hour.fromNow)
            try mailer.sendResetPasswordMail(user: user, accessToken: accessToken, subject: "Reset Password")
        } catch let error as AbortError where error.status == .notFound {
            // ignore "notFound" errors and pretend the operation succeeded for security reasons
        }

        return status("Instructions were sent to the provided email")
    }

    open func update(request: Request) throws -> ResponseRepresentable {
        let user = try userAuthenticator.update(request: request, hasher: hasher)
        return try makeResponse(user: user, responseOptions: .user)
    }
}

private extension UserController {
    func makeResponse(
        user: A.U,
        responseOptions: ResponseOptions
    ) throws -> ResponseRepresentable {
        var response = JSON()

        if responseOptions.contains(.access) {
            try response.set("access_token", makeToken(for: user, expirationDate: 1.hour.fromNow).string)
        }
        if responseOptions.contains(.refresh) {
            try response.set("refresh_token", makeToken(for: user, expirationDate: 1.year.fromNow).string)
        }
        if responseOptions.contains(.user) {
            try response.set("user", user)
        }

        return response
    }

    func makeToken(for user: A.U, expirationDate: Date?) throws -> Token {
        return try Token(user: user, expirationDate: expirationDate, signer: signer)
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
