import Foundation
import JWT
import JWTKeychain

struct UserAccessKeychainConfig: KeychainConfig, Equatable {
    typealias JWTPayload = UserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "access"

    let expirationTimeInterval: TimeInterval = 300
}
