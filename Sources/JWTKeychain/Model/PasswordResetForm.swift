import Forms
import Sugar
import Validation

internal struct PasswordResetForm {
    fileprivate let emailField: NonValidatingFormField<String>
    fileprivate let passwordField: FormField<StrongPassword>

    internal init(email: String?, password: String?, isOptional: Bool) {
        emailField = NonValidatingFormField(
            key: User.Keys.email,
            label: "Email",
            value: email
        )
        passwordField = FormField(
            key: User.Keys.password,
            label: "Password",
            value: password,
            validator: StrongPassword(),
            isOptional: isOptional
        )
    }
}

// MARK: Form

extension PasswordResetForm: Form {
    internal var fields: [FieldsetEntryRepresentable] {
        return [emailField, passwordField]
    }
}

// MARK: PasswordResetInfoType

extension PasswordResetForm: PasswordResetInfoType {
    internal var email: String? {
        return emailField.value
    }

    internal var password: String? {
        return passwordField.value
    }
}
