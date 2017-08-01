import Forms
import Validation
import Vapor

/// Contains the input and validators for a reset password form.
public struct ResetPasswordForm {
    fileprivate struct Keys {
        static let email = User.Keys.email
        static let password = User.Keys.password
        static let passwordConfirmation = "passwordConfirmation"
    }

    internal let email: FormField<EmailValidator>
    internal let password: FormField<StrongPassword>
    internal let passwordConfirmation: FormField<PasswordConfirmationValidator>

    internal init(
        email: String? = nil,
        password: String? = nil,
        passwordConfirmation: String? = nil,
        makeAllFieldsOptional: Bool = false
    ) {
        self.email = FormField(
            label: "Email",
            value: email,
            validator: EmailValidator(),
            isOptional: makeAllFieldsOptional
        )
        self.password = FormField(
            label: "Password",
            value: password,
            validator: StrongPassword(),
            isOptional: makeAllFieldsOptional
        )
        self.passwordConfirmation = FormField(
            label: "Confirm Password",
            value: PasswordConfirmation(
                password: password,
                passwordConfirmation: passwordConfirmation
            ),
            validator: PasswordConfirmationValidator(),
            isOptional: makeAllFieldsOptional
        )
    }
}

// MARK: JSONInitializable

extension ResetPasswordForm: JSONInitializable {
    public init(json: JSON) throws {
        try self.init(
            email: json.get(Keys.email),
            password: json.get(Keys.password),
            passwordConfirmation: json.get(Keys.passwordConfirmation)
        )
    }
}

// MARK: Form

extension ResetPasswordForm: Form {
    public var fieldSetEntries: [FieldSetEntry] {
        return [
            email.makeFieldSetEntry(
                withKey: Keys.email),
            password.makeFieldSetEntry(
                withKey: Keys.password),
            passwordConfirmation.makeFieldSetEntry(
                withKey: Keys.passwordConfirmation)
        ]
    }
}
