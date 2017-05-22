@testable import JWTKeychain
import Authentication

class TestMailer: MailerType {
    var user: MailerUserType?
    var token: Token?
    var subject: String?

    func sendResetPasswordMail<T>(
        user: T,
        token: Token,
        subject: String
        ) throws where T: MailerUserType {
        self.user = user
        self.token = token
        self.subject = subject
    }
}
