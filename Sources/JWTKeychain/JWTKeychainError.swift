import Vapor

public enum JWTKeychainError: String, Error {
    case malformedPayload
}

// MARK: - AbortError
extension JWTKeychainError: AbortError {
    public var reason: String {
        switch self {
        case .malformedPayload: return "Malformed JWT payload received."
        }
    }

    public var status: HTTPResponseStatus {
        switch self {
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
