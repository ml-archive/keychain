import HTTP
import JWT
import Vapor

extension JWTError: AbortError {
    public var status: Status {
        switch self {
        case .missingAlgorithm,
             .missingClaim,
             .signatureVerificationFailed,
             .verificationFailedForClaim,
             .wrongAlgorithm:
            return .unauthorized
        default:
            return .internalServerError
        }
    }

    public var reason: String {
        return description
    }
}
