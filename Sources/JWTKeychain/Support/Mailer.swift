import Vapor
import SMTP
import Transport

public class Mailer: MailerType {
    public let configuration: ConfigurationType

    private let drop: Droplet

    required public init(configuration: ConfigurationType, drop: Droplet) {
        self.configuration = configuration
        self.drop = drop
    }

    /// - Throws: if essential configs are not present
    public func sendResetPasswordMail<T: UserType>(user: T, token: String, subject: String) throws {
        guard let smtpUser = self.drop.config["mail", "user"]?.string,
            let smtpPassword = self.drop.config["mail", "password"]?.string,
            let fromEmail = self.drop.config["mail", "fromEmail"]?.string,
            let fromName = self.drop.config["mail", "fromName"]?.string,
            let smtpHost = self.drop.config["mail", "smtpHost"]?.string,
            let smtpPort = self.drop.config["mail", "smtpPort"]?.int,
            let appUrl = self.drop.config["app", "url"]?.string,
            let appName = self.drop.config["app", "name"]?.string
            else {
                throw Abort.custom(
                    status: .internalServerError,
                    message: "Settings required to send email are not set. Please check mail.json (user, password, fromEmail, smtpHost, smtpPort) and app.json (name, url)."
                )
        }

        let credentials = SMTPCredentials(
            user: smtpUser,
            pass: smtpPassword
        )

        let from = EmailAddress(name: fromName, address: fromEmail)

        // Generate HTML
        let html = try drop.view.make(self.configuration.getResetPasswordEmaiView(),
            [
                "name": appName,
                "user": user.makeNode(),
                "token": token,
                "expire": self.configuration.getResetPasswordTokenExpirationTime(),
                "url": appUrl
            ]
            ).data.string()

        let email: SMTP.Email = Email(
            from: from,
            to: user.email,
            subject: subject,
            body: EmailBody(type: .html, content: html)
        )

        let client = try SMTPClient<TCPClientStream>(
            host: smtpHost,
            port: smtpPort,
            securityLayer: SecurityLayer.tls(nil)
        )
        
        try client.send(email, using: credentials)
    }
}
