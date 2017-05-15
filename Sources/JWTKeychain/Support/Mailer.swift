// TODO: implement using Vapor's MailProtocol

//import Vapor
//import SMTP
//import Transport
//
//public class Mailer: MailerType {
//    public let configuration: ConfigurationType
//
//    private let drop: Droplet
//
//    required public init(configuration: ConfigurationType, drop: Droplet) {
//        self.configuration = configuration
//        self.drop = drop
//    }
//
//    /// - Throws: if essential configs are not present
//    public func sendResetPasswordMail<T: UserType>(user: T, token: String, subject: String) throws {
//        guard let smtpUser = self.drop.config["mail", "user"]?.string,
//            let smtpPassword = self.drop.config["mail", "password"]?.string,
//            let fromEmail = self.drop.config["mail", "fromEmail"]?.string,
//            let fromName = self.drop.config["app", "name"]?.string,
//            let smtpHost = self.drop.config["mail", "smtpHost"]?.string,
//            let smtpPort = self.drop.config["mail", "smtpPort"]?.int
//            else {
//                throw Abort(
//                    .internalServerError,
//                    metadata: "Config required to send email are not set. Please check mail.json (user, password, fromEmail, smtpHost, smtpPort)"
//                )
//        }
//        
//        guard let appUrl = self.drop.config["app", "url"]?.string,
//        let appName = self.drop.config["app", "name"]?.string
//            else {
//                throw Abort(
//                    .internalServerError,
//                    metadata: "Config required to send email are not set. Please check app.json name, url"
//                )
//        }
//        
//
//        let credentials = SMTPCredentials(
//            user: smtpUser,
//            pass: smtpPassword
//        )
//
//        let from = EmailAddress(name: fromName, address: fromEmail)
//
//        // Generate HTML
//        let html = try drop.view.make(self.configuration.getResetPasswordEmaiView(),
//            [
//                "name": .string(appName),
//                // TODO: make User NodeConvertible
////                "user": user.makeNode(),
//                "token": .string(token),
//                "expire": .number(.double(self.configuration.getResetPasswordTokenExpirationTime())),
//                "url": .string(appUrl)
//            ]
//            ).data
//
//        let email: SMTP.Email = Email(
//            from: from,
//            to: user.email,
//            subject: subject,
//            body: EmailBody(type: .html, content: String(describing: html))
//        )
//
//        let client = try SMTPClient<TCPClientStream>(
//            host: smtpHost,
//            port: smtpPort,
//            securityLayer: SecurityLayer.tls(nil)
//        )
//        
//        try client.send(email, using: credentials)
//    }
//}
