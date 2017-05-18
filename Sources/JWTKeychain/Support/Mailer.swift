import Authentication
import SMTP
import Transport
import Vapor

public class Mailer: MailerType {
    private let appConfig: AppConfig
    private let keychainConfig: KeychainConfig
    private let mailConfig: MailConfig
    private let resetPasswordEmailViewPath: String
    private let viewRenderer: ViewRenderer

    required public init(
        appConfig: AppConfig,
        keychainConfig: KeychainConfig,
        mailConfig: MailConfig,
        resetPasswordEmailViewPath: String,
        viewRenderer: ViewRenderer
    ) {
        self.appConfig = appConfig
        self.mailConfig = mailConfig
        self.keychainConfig = keychainConfig
        self.resetPasswordEmailViewPath = resetPasswordEmailViewPath
        self.viewRenderer = viewRenderer
    }

    /// - Throws: if essential configs are not present
    public func sendResetPasswordMail<T: MailerUserType>(
        user: T,
        token: Token,
        subject: String
    ) throws {
        let from = EmailAddress(name: mailConfig.name, address: mailConfig.fromEmail)

        // Generate HTML
        let html = try viewRenderer.make(resetPasswordEmailViewPath,
            [
                "name": .string(appConfig.name),
                "user": user.makeNode(in: nil),
                "token": .string(token.string),
                "expire": .number(.double(keychainConfig.resetPasswordTokenExpirationTime)),
                "url": .string(appConfig.url)
            ]
            ).data.makeString()

        let email = SMTP.Email(
            from: from,
            to: user.emailAddress,
            subject: subject,
            body: EmailBody(type: .html, content: html)
        )

        let credentials = SMTPCredentials(
            user: mailConfig.user,
            pass: mailConfig.password
        )

        let mailer = SMTPMailer(
            scheme: mailConfig.smtpScheme,
            hostname: mailConfig.smtpHost,
            port: mailConfig.smtpPort.port,
            credentials: credentials)

        try mailer.send(email)
    }
}
