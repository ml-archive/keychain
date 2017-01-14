import Vapor
import SMTP
import Transport

public class Mailer {

    /// Sends an email to the user with the password reset URL
    ///
    /// - Parameters:
    ///   - drop: droplet
    ///   - user: user that is resetting the password
    ///   - token: JWT token generated to identify the user
    ///   - resetPasswordEmail: the path to the email view
    ///   - expires: how much time the token will be valid (in minutes)
    /// - Throws: if essential configs are not present
    public static func sendResetPasswordMail(drop: Droplet, user: User, token: String, resetPasswordEmail: String? = nil, expires: Int? = nil) throws {

        guard let smtpUser = drop.config["mail", "user"]?.string,
            let smtpPassword = drop.config["mail", "password"]?.string,
            let fromEmail = drop.config["mail", "fromEmail"]?.string,
            let fromName = drop.config["mail", "fromName"]?.string,
            let smtpHost = drop.config["mail", "smtpHost"]?.string,
            let smtpPort = drop.config["mail", "smtpPort"]?.int,
            let appUrl = drop.config["app", "url"]?.string,
            let appName = drop.config["app", "name"]?.string
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
        let html = try drop.view.make(
            resetPasswordEmail ?? "Emails/reset-password",
            [
                "name": appName,
                "user": user.makeNode(),
                "token": token,
                "expire": expires ?? 0,
                "url": appUrl
            ]
            ).data.string()


        let email: SMTP.Email = Email(
            from: from,
            to: user.email,
            subject: "Reset password",
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
