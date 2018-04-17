import Vapor

extension Request {
    func bearerToken() throws -> String {
        guard
            let authHeader = http.headers[.authorization].first,
            authHeader.starts(with: "Bearer ")
        else {
            throw JWTKeychainError.unauthorized
        }

        return String(authHeader[authHeader.index(authHeader.startIndex, offsetBy: 7)...])
    }

    public func payload<P: JWTKeychainPayload>(payloadType: P.Type = P.self) throws -> P {
        guard let payload = try make(PayloadCache<P>.self).payload else {
            throw JWTKeychainError.unauthorized
        }
        return payload
    }

    public func user<U>(userType: U.Type = U.self) throws -> Future<U> {
        return try make(UserCache<U>.self).user(on: self)
    }
}
