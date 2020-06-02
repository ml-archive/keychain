import Foundation
import JWT
import Keychain

struct UserResetKeychainConfig: KeychainConfig, Equatable {
    typealias JWTPayload = UserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "reset"

    let expirationTimeInterval: TimeInterval = 400
}
