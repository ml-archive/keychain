import Authentication
import JWT
import Vapor

/// Controller for user api requests
open class UserController<U: UserAuthenticating>: UserControllerType {
    private let hasher: HashProtocol
    private let mailer: MailerType
    private let signer: Signer
    private let userAuthenticator: U

    required public init(
        hasher: HashProtocol,
        mailer: MailerType,
        signer: Signer,
        userAuthenticator: U
    ) {
        self.hasher = hasher
        self.mailer = mailer
        self.signer = signer
        self.userAuthenticator = userAuthenticator
    }

    private func makeResponse(token: Token? = nil, user: JSONRepresentable? = nil) throws -> ResponseRepresentable {
        var response = JSON()

        if let token = token {
            try response.set("token", token.string)
        }
        if let user = user {
            try response.set("user", user)
        }

        return response
    }

    open func register(request: Request) throws -> ResponseRepresentable {
        let user = try userAuthenticator.makeUser(request: request, hasher: hasher)
        let token = try user.createToken(using: signer)
        return try makeResponse(token: token, user: user)
    }

    open func logIn(request: Request) throws -> ResponseRepresentable {
        let user = try userAuthenticator.logIn(request: request)
        let token = try user.createToken(using: signer)
        return try makeResponse(token: token, user: user)
    }

    open func logOut(request: Request) throws -> ResponseRepresentable {
        _ = try userAuthenticator.logOut(request: request)
        // TODO: is it really necessary to return this response? A status code of 200 should suffice.
        return try JSON(node: ["success": true])
    }

    open func regenerate(request: Request) throws -> ResponseRepresentable {
        let user = try userAuthenticator.findById(request: request)
        return try makeResponse(token: user.createToken(using: signer))
    }

    open func me(request: Request) throws -> ResponseRepresentable {
        let user = try userAuthenticator.findById(request: request)
        return try makeResponse(user: user)
    }

    open func resetPasswordEmail(request: Request) throws -> ResponseRepresentable {
        do {
            let user = try userAuthenticator.findByEmail(request: request)
            let token = try user.createToken(using: signer)
            try mailer.sendResetPasswordMail(user: user, token: token, subject: "Reset Password")
        } catch let error as AbortError where error.status == .notFound {
            // ignore "notFound" errors and pretend the operation succeeded for security reasons
        }

        // TODO: is it really necessary to return this response? A status code of 200 should suffice.
        return JSON(["success": "Instructions were sent to the provided email"])
    }

    open func update(request: Request) throws -> ResponseRepresentable {
        let user = try userAuthenticator.update(request: request, hasher: hasher)
        return try makeResponse(user: user)
    }
}
