import HTTP
import Vapor

public enum JWTKeychainUserError: Error {
    case missingJSONOnRequest
    case missingEmail
    case missingName
    case missingPassword
    case missingOldPassword
    case userWithGivenEmailAlreadyExists
    case passwordsDoNotMatch
}

extension JWTKeychainUserError: AbortError {
    public var reason: String {
        switch self {
        case .missingJSONOnRequest:
            return "Missing JSON on request."
        case .missingEmail:
            return "Missing value for 'email' in request."
        case .missingName:
            return "Missing value for 'name' in request."
        case .missingPassword:
            return "Missing value for 'password' in request."
        case .missingOldPassword:
            return "Missing value for 'oldPassword' in request."
        case .userWithGivenEmailAlreadyExists:
            return "A user with that email address already exists."
        case .passwordsDoNotMatch:
            return "Passwords do not match"
        }
    }

    public var status: Status {
        return .badRequest
    }
}
