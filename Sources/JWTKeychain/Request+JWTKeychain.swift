import Vapor
import JWTKit

extension Request {
    
    public struct JWTKeychain {
        fileprivate let request: Request

        public func generateAccessToken<P: JWTKeychainAuthenticatable>(for payload: P) throws -> String {
            guard let jwtKeychain = request.application.jwtKeychain else {
                //TODO: add custom error here
                throw Abort(.internalServerError, reason: "JWTKeychain is not set up")
            }
            return try jwtKeychain.accessTokenSigner.sign(payload)
        }

        public func generateRefreshToken<P: JWTKeychainAuthenticatable>(for payload: P) throws -> String {
            guard let jwtKeychain = request.application.jwtKeychain else {
                //TODO: add custom error here
                throw Abort(.internalServerError, reason: "JWTKeychain is not set up")
            }

            guard let refreshTokenSigner = jwtKeychain.refreshTokenSigner else {
                //TODO: add custom error here
                throw Abort(.internalServerError, reason: "refreshTokenSigner is not set up")
            }
            return try refreshTokenSigner.sign(payload)
        }

        public func validateAccessToken<P: JWTKeychainAuthenticatable>(for payload: P) throws {
            guard let jwtKeychain = request.application.jwtKeychain else {
                //TODO: add custom error here
                throw Abort(.internalServerError, reason: "JWTKeychain is not set up")
            }
            try payload.verify(using: jwtKeychain.accessTokenSigner)
        }

        public func validateRefreshToken<P: JWTKeychainAuthenticatable>(for payload: P) throws {
            guard let jwtKeychain = request.application.jwtKeychain else {
                //TODO: add custom error here
                throw Abort(.internalServerError, reason: "JWTKeychain is not set up")
            }

            guard let refreshTokenSigner = jwtKeychain.refreshTokenSigner else {
                //TODO: add custom error here
                throw Abort(.internalServerError, reason: "refreshTokenSigner is not set up")
            }
            try payload.verify(using: refreshTokenSigner)
        }
        
    }

    fileprivate struct Key: StorageKey {
        typealias Value = JWTKeychain
    }

    var jtwKeychain: JWTKeychain {
        get {
            if let existing = storage[Key.self] {
                return existing
            } else {
                let new = JWTKeychain(request: self)
                storage[Key.self] = new
                return new
            }
        }

        set { storage[Key.self] = newValue }
    }
}
