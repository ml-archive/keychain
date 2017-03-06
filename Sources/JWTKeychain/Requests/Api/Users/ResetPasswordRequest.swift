import Vapor
import HTTP
import VaporForms

/// Handles the validation of resetting password
class ResetPasswordRequest: Form {
    let token: String
    let email: String
    let password: String
    let passwordConfirmation: String

    static let fieldset = Fieldset([
        "email": StringField(String.EmailValidator()),
        "password": StringField(String.MinimumLengthValidator(characters: 6), RegexValidator(regex: "^(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])", message: "Must have 1 number and 1 big letter")),
        "password_confirmation": StringField(String.MinimumLengthValidator(characters: 6), RegexValidator(regex: "^(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])", message: "Must have 1 number and 1 big letter")),
        
        // any form of verification in order to get the field passed along
        "token": StringField(String.MinimumLengthValidator(characters: 10))
        ],
        requiring: [
            "token",
            "email",
            "password",
            "password_confirmation"
        ])

    required init(validatedData: [String: Node]) throws {
        // validatedData is guaranteed to contain correct field names and values.
        self.token = validatedData["token"]!.string!
        self.email = validatedData["email"]!.string!
        self.password = validatedData["password"]!.string!
        self.passwordConfirmation = validatedData["password_confirmation"]!.string!
    }
}
