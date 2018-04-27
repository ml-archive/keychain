import Vapor

public enum JWTKeychainError: String, Error {
    case incorrectPassword
}

// MARK: - AbortError
extension JWTKeychainError: AbortError {
    public var reason: String {
        switch self {
        case .incorrectPassword: return "Incorrect password given."
        }
    }

    public var status: HTTPResponseStatus {
        switch self {
        case .incorrectPassword: return .unauthorized
        }
    }
}

// MARK: - Debuggable
extension JWTKeychainError: Debuggable {
    public var identifier: String {
        return rawValue
    }
}
