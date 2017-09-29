import Forms
import HTTP
import Vapor

public enum JWTKeychainUserError: Error {
    case invalidEmail
    case missingEmail
    case missingJSONOnRequest
    case missingName
    case missingOldPassword
    case missingPassword
    case passwordsDoNotMatch
    case userWithGivenEmailAlreadyExists
}

extension JWTKeychainUserError: AbortError {
    public var reason: String {
        switch self {
        case .invalidEmail:
            return "Email is not valid."
        case .missingEmail:
            return "Missing value for 'email' in request."
        case .missingJSONOnRequest:
            return "Missing JSON on request."
        case .missingName:
            return "Missing value for 'name' in request."
        case .missingOldPassword:
            return "Missing value for 'oldPassword' in request."
        case .missingPassword:
            return "Missing value for 'password' in request."
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        case .userWithGivenEmailAlreadyExists:
            return "A user with that email address already exists."
        }
    }

    public var status: Status {
        return .badRequest
    }
}

// MARK: FormFieldValidationError

extension JWTKeychainUserError: FormFieldValidationError {
    public var errorReasons: [String] {
        return [reason]
    }
}
