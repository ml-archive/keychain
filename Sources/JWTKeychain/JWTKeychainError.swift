import Vapor

enum JWTKeychainError: String, Error {
    case invalidIdentifier
    case unauthorized
    case userNotFound
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
