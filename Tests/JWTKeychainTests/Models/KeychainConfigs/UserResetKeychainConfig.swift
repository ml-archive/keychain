import Foundation
import JWT
import JWTKeychain

struct UserResetKeychainConfig: KeychainConfig, Equatable {
    typealias JWTPayload = UserJWTPayload

    static var jwkIdentifier: JWKIdentifier = "reset"

    let expirationTimeInterval: TimeInterval = 400
}
