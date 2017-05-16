import SMTP
import Transport
import Vapor

public class Mailer: MailerType {
    public let configuration: ConfigurationType

    private let drop: Droplet

    required public init(configuration: ConfigurationType, drop: Droplet) {
        self.configuration = configuration
        self.drop = drop
    }

    /// - Throws: if essential configs are not present
    public func sendResetPasswordMail<T: MailerUserType>(
        user: T,
        token: String,
        subject: String) throws
    {
        let config = self.drop.config

        guard let smtpUser = config["mail", "user"]?.string,
            let smtpPassword = config["mail", "password"]?.string,
            let fromEmail = config["mail", "fromEmail"]?.string,
            let fromName = config["app", "name"]?.string,
            let smtpHost = config["mail", "smtpHost"]?.string,
            let smtpPort = config["mail", "smtpPort"]?.int?.port,
            let smtpScheme = config["mail", "smtpScheme"]?.string
            else {
                throw Abort(
                    .internalServerError,
                    metadata: "Config required to send email are not set. Please check mail.json (user, password, fromEmail, smtpHost, smtpPort)"
                )
        }
        
        guard let appUrl = self.drop.config["app", "url"]?.string,
        let appName = self.drop.config["app", "name"]?.string
            else {
                throw Abort(
                    .internalServerError,
                    metadata: "Config required to send email are not set. Please check app.json name, url"
                )
        }

        let from = EmailAddress(name: fromName, address: fromEmail)

        // Generate HTML
        let html = try drop.view.make(self.configuration.getResetPasswordEmailView(),
            [
                "name": .string(appName),
                "user": user.makeNode(in: nil),
                "token": .string(token),
                "expire": .number(.double(self.configuration.getResetPasswordTokenExpirationTime())),
                "url": .string(appUrl)
            ]
            ).data.makeString()

        let email = SMTP.Email(
            from: from,
            to: user.emailAddress,
            subject: subject,
            body: EmailBody(type: .html, content: html)
        )

        let credentials = SMTPCredentials(
            user: smtpUser,
            pass: smtpPassword
        )

        let mailer = SMTPMailer(
            scheme: smtpScheme,
            hostname: smtpHost,
            port: smtpPort,
            credentials: credentials)

        try mailer.send(email)
    }
}
