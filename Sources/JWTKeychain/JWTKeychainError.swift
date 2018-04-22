import Vapor

// TODO: conform to Debuggable
enum JWTKeychainError: String, Error {
    case incorrectPassword
    case invalidCredentials
    case signingError
    case userNotFound
    case weakPassword
}

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
