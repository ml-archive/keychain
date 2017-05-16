import SMTP
import Transport
import Vapor

public class Mailer: MailerType {
//    public let configuration: ConfigurationType
    public let keychainConfig: KeychainConfig
    public let mailConfig: MailConfig
    public let appConfig: AppConfig
//    private let drop: Droplet

//    required public init(configuration: ConfigurationType, drop: Droplet) {
//        self.configuration = configuration
//        self.drop = drop
//    }

    required public init(
        keychainConfig: KeychainConfig,
        mailConfig: MailConfig,
        appConfig: AppConfig
    ) {
        self.keychainConfig = keychainConfig
        self.mailConfig = mailConfig
        self.appConfig = appConfig
    }

    /// - Throws: if essential configs are not present
    public func sendResetPasswordMail<T: MailerUserType>(
        user: T,
        token: String,
        subject: String
    ) throws {
        let from = EmailAddress(name: mailConfig.name, address: mailConfig.fromEmail)

        // Generate HTML
        // TODO: Figure out where to put this
//        let html = try drop.view.make(resetPasswordEmailViewPath,
//            [
//                "name": .string(appName),
//                "user": user.makeNode(in: nil),
//                "token": .string(token),
//                "expire": .number(.double(resetPasswordTokenExpirationTime)),
//                "url": .string(appUrl)
//            ]
//            ).data.makeString()

        let html = ""

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
