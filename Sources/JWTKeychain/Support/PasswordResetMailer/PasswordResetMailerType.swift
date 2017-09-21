import Authentication
import SMTP
import Vapor

/// Defines types that can send password reset emails.
public protocol PasswordResetMailerType {
    typealias User = NodeRepresentable & EmailAddressRepresentable

    func sendResetPasswordMail<T: User>(
        user: T,
        resetToken: Token,
        subject: String
    ) throws
}
