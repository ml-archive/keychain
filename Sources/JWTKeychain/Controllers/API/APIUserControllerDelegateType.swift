import Vapor
import HTTP

public protocol APIUserControllerDelegateType {
    func register(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable

    func logIn(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable

    func logOut(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable

    func regenerate(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable

    func me(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable

    func resetPasswordEmail(
        request: Request,
        tokenGenerators: TokenGenerators,
        passwordResetMailer: PasswordResetMailerType
    ) throws -> ResponseRepresentable

    func update(
        request: Request,
        tokenGenerators: TokenGenerators
    ) throws -> ResponseRepresentable
}
