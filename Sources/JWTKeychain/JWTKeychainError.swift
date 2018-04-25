import Vapor

public enum JWTKeychainError: String, Error {
    case incorrectPassword
    case userNotFound
}

// MARK: - AbortError
extension JWTKeychainError: AbortError {
    public var reason: String {
        return "Unauthorized"
    }

    public var status: HTTPResponseStatus {
        return .unauthorized
    }
}

// MARK: - Debuggable
extension JWTKeychainError: Debuggable {
    public var identifier: String {
        return rawValue
    }
}
