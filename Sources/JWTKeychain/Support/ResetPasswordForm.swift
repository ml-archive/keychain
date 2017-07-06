import Vapor

public struct ResetPasswordForm {
    private struct Keys {
        static let email = "email"
        static let password = "password"
        static let passwordConfirmation = "passwordConfirmation"
    }

    public let email: FormField<Email>
    public let password: FormField<Password>
    public let passwordConfirmation: FormField<PasswordPair>

    public init(content: Content) {
        email = FormField(content[Keys.email]?.string ?? "", name: Keys.email)

        let rawPassword = content[Keys.password]?.string ?? ""
        password = FormField(rawPassword, name: Keys.password)

        let rawPasswordConfirmation = content[Keys.passwordConfirmation]?.string ?? ""
        passwordConfirmation = FormField(Pair(left: rawPassword, right: rawPasswordConfirmation), name: Keys.passwordConfirmation)
    }
}
