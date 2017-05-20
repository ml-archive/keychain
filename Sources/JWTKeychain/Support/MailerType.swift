import Authentication
import SMTP
import Vapor

/// Defines basic email functionality.
public protocol MailerType {
    typealias MailerUserType = NodeRepresentable & EmailAddressRepresentable

    /// Initializes the Mailer with the JWT configuration.
    // TODO: update header doc
    init(
        appConfig: AppConfig,
        keychainConfig: KeychainConfig,
        mailConfig: MailConfig,
        resetPasswordEmailViewPath: String,
        viewRenderer: ViewRenderer
    )

    /// Sends an email to the user with the password reset URL
    ///
    /// - Parameters:
    ///   - user: user that is resetting the password
    ///   - token: JWT token generated to identify the user
    /// - Throws: if essential configs are not present
    func sendResetPasswordMail<T: MailerUserType>(user: T, token: Token, subject: String) throws
}
