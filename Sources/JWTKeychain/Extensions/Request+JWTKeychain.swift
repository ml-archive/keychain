import Vapor

public extension Request {
    struct Keychain {
        let request: Request

        public func config<T: KeychainConfig>(for jwkIdentifiableType: T.Type) -> T {
            request.application.keychain.config(for: jwkIdentifiableType)
        }
    }

    var keychain: Keychain { .init(request: self) }
}
