@testable import JWTKeychain
import Authentication

class TestPaswordResetMailer: PasswordResetMailerType {
    var capturedUser: PasswordResetMailerType.User?
    var capturedResetToken: Token?
    var capturedSubject: String?

    func sendResetPasswordMail<T>(
        user: T,
        resetToken: Token,
        subject: String
    ) throws where T: PasswordResetMailerType.User {
        capturedUser = user
        capturedResetToken = resetToken
        capturedSubject = subject
    }
}
