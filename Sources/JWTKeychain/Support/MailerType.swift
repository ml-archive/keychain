import Authentication
import SMTP
import Vapor

/// Defines basic email functionality.
public protocol MailerType {
    typealias MailerUserType = NodeRepresentable & EmailAddressRepresentable

    /// Sends an email to the user with the password reset URL
    ///
    /// - Parameters:
    ///   - user: user that is resetting the password
    ///   - token: JWT token generated to identify the user
    /// - Throws: if HTML cannot be created or mail cannot be sent
    func sendResetPasswordMail<T: MailerUserType>(
        user: T,
        accessToken: Token,
        subject: String
    ) throws
}
