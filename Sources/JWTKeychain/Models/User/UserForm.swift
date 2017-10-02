import Forms
import JSON
import Sugar
import Validation

internal struct UserForm {
    fileprivate let emailField: FormField<String>
    fileprivate let nameField: FormField<String>
    fileprivate let passwordField: FormField<String>
    fileprivate let passwordRepeatField: FormField<String>
    fileprivate let oldPasswordField: FormField<String>

    internal init(
        email: String?,
        name: String?,
        password: String?,
        passwordRepeat: String?,
        oldPassword: String?
    ) {
        emailField = FormField(
            value: email,
            validator: OptionalValidator(
                errorOnNil: JWTKeychainUserError.missingEmail) {
                    // Transform the validation error
                    do {
                        try EmailValidator().validate($0)
                    } catch {
                        throw JWTKeychainUserError.invalidEmail
                    }
                }
        )
        nameField = FormField(
            value: name,
            validator: OptionalValidator(
                errorOnNil: JWTKeychainUserError.missingName
            )
        )
        passwordField = FormField(
            value: password,
            validator: OptionalValidator(
                errorOnNil: JWTKeychainUserError.missingPassword
            ) {
                do {
                    try StrongPassword().validate($0)
                } catch {
                    throw JWTKeychainUserError.passwordTooWeak
                }
            }
        )
        passwordRepeatField = FormField(value: passwordRepeat)
        oldPasswordField = FormField(value: oldPassword)
    }
}

// MARK: Convenience accessors

extension UserForm {
    var email: String? {
        return emailField.value
    }

    var name: String? {
        return nameField.value
    }

    var password: String? {
        return passwordField.value
    }

    var passwordRepeat: String? {
        return passwordRepeatField.value
    }

    var oldPassword: String? {
        return oldPasswordField.value
    }
}

// MARK: Form

extension UserForm: Form {
    var fields: [FieldType] {
        return [
            emailField,
            nameField,
            passwordField,
            passwordRepeatField,
            oldPasswordField
        ]
    }
}

// MARK: JSONInitializable

extension UserForm: JSONInitializable {
    internal init(json: JSON) throws {
        try self.init(
            email: json.get(User.Keys.email),
            name: json.get(User.Keys.name),
            password: json.get(User.Keys.password),
            passwordRepeat: json.get(User.Keys.passwordRepeat),
            oldPassword: json.get(User.Keys.oldPassword)
        )
    }
}
