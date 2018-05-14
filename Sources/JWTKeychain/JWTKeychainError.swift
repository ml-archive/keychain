import Vapor

public enum JWTKeychainError: String, Error {
    case incorrectPassword
    case malformedPayload
}

// MARK: - AbortError
extension JWTKeychainError: AbortError {
    public var reason: String {
        switch self {
        case .incorrectPassword: return "Incorrect password given."
        case .malformedPayload: return "Malformed JWT payload received."
        }
    }

    public var status: HTTPResponseStatus {
        switch self {
        case .incorrectPassword: return .unauthorized
        case .malformedPayload: return .badRequest
        }
    }
}

// MARK: - Debuggable
extension JWTKeychainError: Debuggable {
    public var identifier: String {
        return rawValue
    }
}
