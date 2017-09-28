import Forms
import Sugar
import Validation

internal struct PasswordResetForm {
    fileprivate let emailField: FormField<String>
    fileprivate let passwordField: FormField<String>
    fileprivate let passwordRepeatField: FormField<String>

    internal init(email: String?, password: String?, passwordRepeat: String?) {
        emailField = FormField(
            key: User.Keys.email,
            label: "Email",
            value: email,
            validator: OptionalValidator()
        )
        passwordField = FormField(
            key: User.Keys.password,
            label: "Password",
            value: password,
            validator: OptionalValidator(validator: PasswordValidator())
        )
        passwordRepeatField = FormField(
            key: User.Keys.passwordRepeat,
            label: "Repeat Password",
            value: passwordRepeat) {
                if $0 != password {
                    throw JWTKeychainUserError.passwordsDoNotMatch
                }
        }
    }
}

// MARK: Form

extension PasswordResetForm: Form {
    internal var fields: [FieldsetEntryRepresentable] {
        return [emailField, passwordField, passwordRepeatField]
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

// MARK: PasswordValidator

/// Wrapper for `StrongPassword` from `Sugar`.
/// Transforms thrown error to `ValidatorError`s.
private struct PasswordValidator: Validator {
    func validate(_ input: String) throws {
        do {
            try StrongPassword().validate(input)
        } catch {
            throw ValidatorError.failure(
                type: "",
                reason: "Password is too weak."
            )
        }
    }
}
