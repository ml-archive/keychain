import Vapor

/// Represents JWTKeychain specific errors.
public enum JWTKeychainError: String, Error {
    case malformedPayload
}

// MARK: - AbortError
extension JWTKeychainError: AbortError {

    /// See `AbortError`.
    public var reason: String {
        switch self {
        case .malformedPayload: return "Malformed JWT payload received."
        }
    }

    /// See `AbortError`.
    public var status: HTTPResponseStatus {
        switch self {
        case .malformedPayload: return .badRequest
        }
    }
}

// MARK: - Debuggable
extension JWTKeychainError: Debuggable {

    /// See `Debuggable`.
    public var identifier: String {
        return rawValue
    }
}
