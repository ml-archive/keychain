import Authentication
import Foundation
import SMTP
import Transport
import Vapor

public class PasswordResetMailer: PasswordResetMailerType {
    private let baseURL: String
    private let expireIn: DateComponents
    private let fromEmailAddress: EmailAddress
    private let mailer: MailProtocol
    private let pathToEmailView: String
    private let viewRenderer: ViewRenderer

    public init(
        mailer: MailProtocol,
        settings: Settings,
        viewRenderer: ViewRenderer
    ) {
        self.baseURL = settings.baseURL
        self.expireIn = settings.resetPassword.expireIn
        self.fromEmailAddress = settings.fromEmailAddress
        self.mailer = mailer
        self.pathToEmailView = settings.pathToEmailView
        self.viewRenderer = viewRenderer
    }

    /// Sends an email to the user with the password reset URL
    ///
    /// - Parameters:
    ///   - user: user that is resetting the password
    ///   - resetToken: JWT that the user can be use to reset their password
    ///   - subject: subject of the email
    /// - Throws: if HTML cannot be created or mail cannot be sent
    public func sendResetPasswordMail<T: PasswordResetMailerType.User>(
        user: T,
        resetToken: Token,
        subject: String
    ) throws {
        let html = try viewRenderer
            .make(
                pathToEmailView,
                ViewData(
                    node: [
                        "user": user.makeNode(in: jsonContext),
                        "token": resetToken.string,
                        "expire": expireIn.minute ?? 0,
                        "url": baseURL
                    ]
                )
            )
            .data
            .makeString()

        let email = SMTP.Email(
            from: fromEmailAddress,
            to: user.emailAddress,
            subject: subject,
            body: EmailBody(type: .html, content: html)
        )

        try mailer.send(email)
    }
}
