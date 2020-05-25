import JWT
import Vapor

public extension Application {
    struct Keychain {
        fileprivate struct Key: StorageKey {
            typealias Value = Keychain
        }

        let application: Application

        public func config<T: KeychainConfig>(for jwkIdentifiableType: T.Type) -> T {
            application.storage[JWKStorageKey<T>.self]!
        }

        public func configure<T: KeychainConfig>(signer: JWTSigner, config: T) {
            application.jwt.signers.use(signer, kid: T.jwkIdentifier)
            application.storage[JWKStorageKey<T>.self] = config
        }
    }

    var keychain: Keychain {
        get {
            storage[Keychain.Key.self, orSetDefault: Keychain(application: self)]
        }
        set {
            storage[Keychain.Key.self] = newValue
        }
    }
}

private struct JWKStorageKey<Config: KeychainConfig>: StorageKey {
    typealias Value = Config
}
