import JWT

public protocol JWTKeychainPayload: JWTPayload {
    var exp: ExpirationClaim { get }
    var sub: SubjectClaim { get }
    var verifiables: [JWTVerifiable] { get }
}

extension JWTKeychainPayload {
    public var verifiables: [JWTVerifiable] {
        return [exp]
    }

    func verify() throws {
        try verifiables.forEach { try $0.verify() }
    }
}

public struct Payload: JWTKeychainPayload {
    public let exp: ExpirationClaim
    public let sub: SubjectClaim

    public func verify() throws {
        try exp.verify()
    }
}
