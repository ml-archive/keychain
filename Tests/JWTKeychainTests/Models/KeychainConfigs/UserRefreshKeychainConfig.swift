import Foundation
import JWT
import JWTKeychain

struct UserRefreshKeychainConfig: KeychainConfig, Equatable {
    typealias JWTPayload = UserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "refresh"

    let expirationTimeInterval: TimeInterval = 600
}
