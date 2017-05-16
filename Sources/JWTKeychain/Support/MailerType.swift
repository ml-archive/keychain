import SMTP
import Vapor

/// Defines basic email functionality.
public protocol MailerType {

    typealias MailerUserType = NodeConvertible & EmailAddressRepresentable

    /// Initializes the Mailer with the JWT configuration.
    ///
    /// - Parameters:
    /// configuration : the JWT configuration.
    /// drop : the Droplet instance
//    init(configuration: ConfigurationType, drop: Droplet)
    init(
        keychainConfig: KeychainConfig,
        mailConfig: MailConfig,
        appConfig: AppConfig
    )

    /// Sends an email to the user with the password reset URL
    ///
    /// - Parameters:
    ///   - user: user that is resetting the password
    ///   - token: JWT token generated to identify the user
    /// - Throws: if essential configs are not present
    func sendResetPasswordMail<T: MailerUserType>(user: T, token: String, subject: String) throws
}
