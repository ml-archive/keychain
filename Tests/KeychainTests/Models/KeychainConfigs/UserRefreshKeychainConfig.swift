import Foundation
import JWT
import Keychain

struct UserRefreshKeychainConfig: KeychainConfig, Equatable {
    typealias JWTPayload = UserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "refresh"

    let expirationTimeInterval: TimeInterval = 600
}
