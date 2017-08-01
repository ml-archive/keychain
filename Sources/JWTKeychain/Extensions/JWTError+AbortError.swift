import HTTP
import JWT
import Vapor

// TODO: should this be changed after recent JWTProvider error changes?
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
