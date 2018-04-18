import Vapor

enum JWTKeychainError: String, Error {
    case incorrectPassword
    case invalidIdentifier
    case unauthorized
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
