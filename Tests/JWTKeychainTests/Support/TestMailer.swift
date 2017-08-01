@testable import JWTKeychain
import Authentication

class TestMailer: MailerType {
    var user: MailerUserType?
    var accessToken: Token?
    var subject: String?

    func sendResetPasswordMail<T>(
        user: T,
        accessToken: Token,
        subject: String
        ) throws where T: MailerUserType {
        self.user = user
        self.accessToken = accessToken
        self.subject = subject
    }
}
