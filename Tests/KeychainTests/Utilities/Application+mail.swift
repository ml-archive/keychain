import Keychain
import Vapor

extension Application {
    final class Mail {
        fileprivate struct Key: StorageKey {
            typealias Value = Mail
        }

        var capturedToken: String?
        var capturedUser: User?
        var capturedConfig: UserResetKeychainConfig?

        func sendToken(_ token: String, to user: User, using config: UserResetKeychainConfig) {
            capturedToken = token
            capturedUser = user
            capturedConfig = config
        }
    }

    var mail: Mail {
        guard let value = storage[Mail.Key.self] else {
            let value = Mail()
            storage[Mail.Key.self] = value
            return value
        }
        return value
    }

}
