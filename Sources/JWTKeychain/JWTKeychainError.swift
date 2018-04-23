import Vapor

enum JWTKeychainError: String, Error, Debuggable {
    case incorrectPassword
    case invalidCredentials
    case signingError
    case userNotFound
    case weakPassword
}

// MARK: - AbortError
extension JWTKeychainError: AbortError {
    var identifier: String {
        return rawValue
    }

    var reason: String {
        return "Unauthorized"
    }

    var status: HTTPResponseStatus {
        return .unauthorized
    }
}
