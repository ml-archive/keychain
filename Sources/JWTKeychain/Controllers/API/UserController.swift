import Authentication
import Flash
import Fluent
import Foundation
import HTTP
import JWT
import SMTP
import Vapor

public protocol TokenCreating {
    func createToken(using: Signer) throws -> Token
}

public protocol UserAuthenticating: EmailAddressRepresentable, JSONRepresentable, NodeRepresentable,
RequestInitializable, TokenCreating {
    static func findByEmail(request: Request) throws -> Self
    static func findById(request: Request) throws -> Self
    static func logIn(request: Request) throws -> Self
    static func logOut(request: Request) throws -> Self
    static func update(request: Request) throws -> Self
}

extension UserAuthenticating where Self: Entity {
    public static func findById(request: Request) throws -> Self {
        let id = try request.data.get("id") as Identifier

        guard let user = try find(id) else {
            throw Abort.notFound
        }

        return user
    }

    public static func logIn(request: Request) throws -> Self {
        return try findById(request: request)
    }

    public static func logOut(request: Request) throws -> Self {
        return try findById(request: request)
    }
}

public protocol HasEmail: Entity {
    var email: String { get }
}

extension UserAuthenticating where Self: HasEmail {
    public static func findByEmail(request: Request) throws -> Self {
        // TODO: define "email", "id", "name", "password". in an enum to avoid string typing
        let email = try request.data.get("email") as String

        guard let user = try Self.makeQuery().filter("email", email).first() else {
            throw Abort.badRequest
        }

        return user
     }
}

/// Controller for user api requests
open class UserController<U: UserAuthenticating>: UserControllerType {

    private let mailer: MailerType
    private let signer: Signer
    private let userType: U.Type
    
    required public init(mailer: MailerType, signer: Signer, userType: U.Type) {
        self.mailer = mailer
        self.signer = signer
        self.userType = userType
    }

    private func makeResponse(token: Token? = nil, user: JSONRepresentable? = nil) throws -> ResponseRepresentable {
        var response = JSON()

        if let token = token {
            try response.set("token", token)
        }
        if let user = user {
            try response.set("user", user)
        }

        return response
    }

    open func register(request: Request) throws -> ResponseRepresentable {
        let user = try userType.init(request: request)
        let token = try user.createToken(using: signer)
        return try makeResponse(token: token, user: user)
    }

    open func login(request: Request) throws -> ResponseRepresentable {
        let user = try userType.logIn(request: request)
        let token = try user.createToken(using: signer)
        return try makeResponse(token: token, user: user)
    }

    open func logout(request: Request) throws -> ResponseRepresentable {
        _ = try userType.logOut(request: request)
        return try JSON(node: ["success": true])
    }

    open func regenerate(request: Request) throws -> ResponseRepresentable {
        let user = try userType.findById(request: request)
        return try makeResponse(token: user.createToken(using: signer))
    }

    open func me(request: Request) throws -> ResponseRepresentable {
        let user = try userType.findById(request: request)
        return try makeResponse(user: user)
    }

    open func resetPasswordEmail(request: Request) throws -> ResponseRepresentable {
        do {
            let user = try userType.findByEmail(request: request)
            let token = try user.createToken(using: signer)
            try mailer.sendResetPasswordMail(user: user, token: token, subject: "Reset Password")
        } catch let error as AbortError where error.status == .notFound {
            // ignore "notFound" errors
        }

        // the response will be the same regardless of success to prevent people from
        return JSON(["success": "Instructions were sent to the provided email"])
    }

    open func update(request: Request) throws -> ResponseRepresentable {
        let user = try userType.update(request: request)
        return try makeResponse(user: user)
    }
}
